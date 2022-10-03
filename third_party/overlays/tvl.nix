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
      version = "1.8.4";
      src = self.fetchFromGitHub {
        owner = "tdlib";
        repo = "td";
        rev = "7eabd8ca60de025e45e99d4e5edd39f4ebd9467e";
        sha256 = "1chs0ibghjj275v9arsn3k68ppblpm7ysqk0za9kya5vdnldlld5";
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


  # Build electrum with protobuf >= 4 by following hypothetical instructions from
  # upstream commit that pins to < 4
  # https://github.com/spesmilo/electrum/commit/52b73880f95be5cf51742fec10cde0a2e4b23de4
  # https://github.com/NixOS/nixpkgs/pull/194112
  electrum = super.electrum.overrideAttrs (old: {
    postPatch = ''
      # make compatible with protobuf4 by easing dependencies ...
      substituteInPlace ./contrib/requirements/requirements.txt \
        --replace "protobuf>=3.12,<4" "protobuf>=3.12"
      # ... and regenerating the paymentrequest_pb2.py file
      protoc --python_out=. electrum/paymentrequest.proto
    '' + old.postPatch or "";
  });
}
