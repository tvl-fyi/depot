# This file controls the import of external dependencies (i.e.
# third-party code) into my package tree.
#
# This includes *all packages needed from nixpkgs*.
{ ... }:

let
  # Tracking nixos-unstable as of 2020-12-28.
  nixpkgsCommit = "2f47650c2f28d87f86ab807b8a339c684d91ec56";
  nixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsCommit}.tar.gz";
    sha256 = "17akl75x28rzq97gaad32flswdsp150nfsg7h909kda721zql71a";
  };
  nixpkgs = import nixpkgsSrc {
    config.allowUnfree = true;
    config.allowBroken = true;

    # Lutris depends on p7zip, which is considered insecure.
    config.permittedInsecurePackages = [
      "p7zip-16.02"
    ];
  };

  # Tracking nixos-20.09 as of 2020-12-28.
  stableCommit = "0c81b9a4f170f734bd7e587a39e56470c59733e7";
  stableNixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${stableCommit}.tar.gz";
    sha256 = "1fl5ks6p78bamqanbk9xpy83jzzcdw2mdabrp59n33xv7jix1jzx";
  };
  stableNixpkgs = import stableNixpkgsSrc {};

  exposed = import ./nixpkgs-exposed.nix { inherit nixpkgs stableNixpkgs; };

in exposed.lib.fix(self: exposed // {
  callPackage = nixpkgs.lib.callPackageWith self;

  # Provide the source code of nixpkgs, but do not provide an imported
  # version of it.
  inherit nixpkgsCommit nixpkgsSrc stableNixpkgsSrc;

  # Packages to be overridden
  originals = {
    inherit (nixpkgs) gtest openldap go grpc notmuch rr;
    inherit (stableNixpkgs) git;
    ffmpeg = nixpkgs.ffmpeg-full;
  };

  # Use LLVM 11
  llvmPackages = nixpkgs.llvmPackages_11;
  clangStdenv = nixpkgs.llvmPackages_11.stdenv;
  stdenv = nixpkgs.llvmPackages_11.stdenv;

  clang-tools = (nixpkgs.clang-tools.override {
    llvmPackages = nixpkgs.llvmPackages_11;
  });

  # Provide Emacs 27
  #
  # The assert exists because the name of the attribute is unversioned
  # (which is different from previous versions).
  emacs27 = assert ((exposed.lib.versions.major nixpkgs.emacs.version) == "27");
    nixpkgs.emacs.overrideAttrs(old: {
      configureFlags = old.configureFlags ++ [ "--with-cairo" ];
    });

  emacs27-nox = assert ((exposed.lib.versions.major nixpkgs.emacs.version) == "27");
    nixpkgs.emacs-nox;

  # The Go authors have released a version of Go (in alpha) that has a
  # type system. This makes it available, specifically for use with
  # //nix/buildTypedGo.
  go = nixpkgs.go.overrideAttrs(old: {
    version = "dev-go2go";
    doCheck = false;
    patches = []; # they all don't apply and are mostly about Darwin crap

    src = nixpkgs.fetchgit {
      url = "https://go.googlesource.com/go";
      # You might think these hashes are trivial to update. It's just
      # a branch in a git repository, right?
      #
      # Well, think again. Somehow I managed to get no fewer than 3
      # (!) different commit hashes for the same branch by cloning
      # this repository thrice. Only the third one (which you, the
      # reader, can find below for your reading pleasure) actually
      # gave me `go tool go2go`.
      rev = "ad307489d41133f32c779cfa1b0db4a852ace047";
      leaveDotGit = true;
      sha256 = "1nxmqdlyfx7w3g5vhjfq24yrc9hwpsa2mjv58xrmhh8vvy50ziqq";

      postFetch = ''
        cd $out
        ${nixpkgs.git}/bin/git log -n 1 "--format=format:devel +%H %cd" HEAD > VERSION
        rm -rf .git
      '';
    };
  });

  # Make NixOS available
  nixos = import "${nixpkgsSrc}/nixos";
})
