# This overlay is used to make TVL-specific modifications in the
# nixpkgs tree, where required.
{ depot, ... }:

self: super:
let
  # Rollback Nix to a stable version (2.3) with backports for
  # build-user problems applied.
  nixSrc =
    let
      # branch 2.3-backport-await-users
      rev = "46a91f2abaee85135cbb447c13957d3c5e9091a9";
    in
    self.fetchFromGitHub
      {
        owner = "tvlfyi";
        repo = "nix";
        inherit rev;
        hash = "sha256:0rwyrh471c5y64axyd8vzzzmzlscg97fsrjbgbm1a93wnzxcvnvk";
      } // { revCount = 0; shortRev = builtins.substring 0 7 rev; };
in
{
  nix = (import "${nixSrc}/release.nix" {
    nix = nixSrc;
    nixpkgs = super.path;
    systems = [ builtins.currentSystem ];
  }).build."${builtins.currentSystem}";

  nix_latest = super.nix;

  home-manager = super.home-manager.overrideAttrs (_: {
    src = depot.third_party.sources.home-manager;
    version = "git-"
      + builtins.substring 0 7 depot.third_party.sources.home-manager.rev;
  });

  clang-tools_11 = self.clang-tools.override {
    llvmPackages = self.llvmPackages_11;
  };

  # stdenv which uses clang, lld and libc++; full is a slight exaggeration,
  # we for example don't use LLVM's libunwind
  fullLlvm11Stdenv = self.overrideCC self.stdenv
    (self.llvmPackages_11.libcxxStdenv.cc.override {
      inherit (self.llvmPackages_11) bintools;
    });

  # Add our Emacs packages to the fixpoint
  emacsPackagesFor = emacs: (
    (super.emacsPackagesFor emacs).overrideScope' (eself: esuper: {
      tvlPackages = depot.tools.emacs-pkgs // depot.third_party.emacs;

      # Use the notmuch from nixpkgs instead of from the Emacs
      # overlay, to avoid versions being out of sync.
      notmuch = super.notmuch.emacs;

      # Build EXWM with the depot sources instead.
      exwm = esuper.exwm.overrideAttrs (_: {
        src = depot.path.origSrc + "/third_party/exwm";
      });

      # Workaround for magit checking the git version at load time
      magit = esuper.magit.overrideAttrs (_: {
        propagatedNativeBuildInputs = [
          self.git
        ];
      });
    })
  );

  # Upgrade to match telega in emacs-overlay
  # TODO(tazjin): ugrade tdlib (+ telega?!) in nixpkgs
  tdlib = assert super.tdlib.version == "1.8.3";
    super.tdlib.overrideAttrs (old: {
      version = "1.8.7";
      src = self.fetchFromGitHub {
        owner = "tdlib";
        repo = "td";
        rev = "a7a17b34b3c8fd3f7f6295f152746beb68f34d83";
        sha256 = "sha256:0a5609knn7rmiiblz315yrvc9f2r207l2nl6brjy5bnhjdspmzs6";
      };
    });

  # dottime support for notmuch
  notmuch = super.notmuch.overrideAttrs (old: {
    passthru = old.passthru // {
      patches = old.patches ++ [ ./patches/notmuch-dottime.patch ];
    };
  });

  # nix-serve does not work with nix 2.4
  # https://github.com/edolstra/nix-serve/issues/28
  nix-serve = super.nix-serve.override { nix = super.nix_2_3; };

  # Avoid builds of mkShell derivations in CI.
  mkShell = super.lib.makeOverridable (args: (super.mkShell args).overrideAttrs (_: {
    passthru = {
      meta.ci.skip = true;
    };
  }));
}
