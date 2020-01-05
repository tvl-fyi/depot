# This file controls the import of external dependencies (i.e.
# third-party code) into my package tree.
#
# This includes *all packages needed from nixpkgs*.

{ pkgs, ... }:
let
  commit = "e0470e11c7a02f9e6e70f5ec5e1d9470c742b396";
  nixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${commit}.tar.gz";
    sha256 = "1amczhr8m7lvxnxzwhfamz4ga78sgnyzdfr759iq26azkh6fa03a";
  };
  nixpkgs = import nixpkgsSrc {
    config.allowUnfree = true;
    config.allowBroken = true;
  };

  exposed = {
    # Inherit the packages from nixpkgs that should be available inside
    # of the repo. They become available under `pkgs.third_party.<name>`
    inherit (nixpkgs)
      age
      bashInteractive
      bat
      buildGoPackage
      cacert
      cachix
      cargo
      cgit
      coreutils
      darwin
      dockerTools
      emacs26
      emacs26-nox
      emacsPackagesNg
      emacsPackagesNgGen
      fetchFromGitHub
      fetchurl
      fira
      fira-code
      fira-mono
      gettext
      glibc
      gnutar
      go
      google-cloud-sdk
      gzip
      haskell
      iana-etc
      imagemagickBig
      jq
      kontemplate
      lib
      lispPackages
      llvmPackages
      luatex
      makeFontsConf
      makeWrapper
      mdbook
      mime-types
      moreutils
      nano
      nginx
      nix
      openssh
      openssl
      parallel
      pkgconfig
      protobuf
      python3Packages
      remarshal
      rink
      ripgrep
      rsync
      runCommand
      rustPlatform
      rustc
      sbcl
      stdenv
      stern
      symlinkJoin
      systemd
      tdlib
      terraform_0_12
      texlive
      thttpd
      tree
      writeShellScript
      writeShellScriptBin
      writeText
      writeTextFile
      zlib
      zstd;
  };

in exposed // {
  callPackage = nixpkgs.lib.callPackageWith exposed;

  # Provide the source code of nixpkgs, but do not provide an imported
  # version of it.
  inherit nixpkgsSrc;

  # Packages to be overridden
  originals = {
    inherit (nixpkgs) git notmuch;
  };

  # Make NixOS available
  nixos = import "${nixpkgsSrc}/nixos";
}
