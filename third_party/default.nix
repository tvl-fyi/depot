# This file controls the import of external dependencies (i.e.
# third-party code) into my package tree.
#
# This includes *all packages needed from nixpkgs*.
{ ... }:

let
  # Tracking nixos-20.03 as of 2020-04-21.
  commit = "1e90c46c2d98f9391df79954a74d14f263cad729";
  nixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${commit}.tar.gz";
    sha256 = "1xs0lgh3q1hbrj0lbpy3czw41cv6vxx9kdf2npwc58z8xq3sdqmh";
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
      autoconf
      bashInteractive
      bat
      buildGoModule
      buildGoPackage
      bzip2
      c-ares
      cacert
      cachix
      cairo
      cargo
      cgit
      clang_9
      cmake
      coreutils
      cudatoolkit
      darwin
      dockerTools
      emacs26
      emacs26-nox
      emacsPackages
      emacsPackagesGen
      fetchFromGitHub
      fetchurl
      fetchzip
      fira
      fira-code
      fira-mono
      fontconfig
      freetype
      gettext
      glibc
      gnutar
      go
      google-cloud-sdk
      graphviz
      grpc
      gzip
      haskell
      iana-etc
      imagemagickBig
      jetbrains-mono
      jq
      kontemplate
      lib
      libredirect
      llvmPackages
      luajit
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
      overrideCC
      overrideCCC
      pandoc
      parallel
      pkgconfig
      pounce
      protobuf
      python3
      python3Packages
      remarshal
      rink
      ripgrep
      rsync
      runCommand
      runCommandNoCC
      rustPlatform
      rustc
      sbcl
      sqlite
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
      xz
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
    ffmpeg = nixpkgs.ffmpeg-full;
  };

  # Make NixOS available
  nixos = import "${nixpkgsSrc}/nixos";

  # Build a Chromium with VAAPI (hardware-accelerated video decoding)
  # enabled. This is useful for Stadia on desktop.
  chromiumVaapi = nixpkgs.chromium.override {
    useVaapi = true;
  };
}
