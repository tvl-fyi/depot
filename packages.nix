# This file contains configuration for packages to install.
# It does not contain configuration for software that is already covered
# by other NixOS options (e.g. emacs)

{ config, pkgs, ... }:

let
  fetchChannel = { rev, sha256 }: import (fetchTarball {
    inherit sha256;
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
  }) { config.allowUnfree = true; };

  # Channels last updated: 2018-06-15

  # Instead of relying on Nix channels and ending up with out-of-sync
  # situations between machines, the commit for the stable Nix channel
  # is pinned here.
  stable = fetchChannel {
    rev    = "08d245eb31a3de0ad73719372190ce84c1bf3aee";
    sha256 = "1g22f8r3l03753s67faja1r0dq0w88723kkfagskzg9xy3qs8yw8";
  };

  # Certain packages from unstable are hand-picked into the package
  # set.
  unstable = fetchChannel {
    rev    = "4b649a99d8461c980e7028a693387dc48033c1f7";
    sha256 = "0iy2gllj457052wkp20baigb2bnal9nhyai0z9hvjr3x25ngck4y";
  };

  # Haskell IDE engine:
  hieCommit = "8f04568aa8c3215f543250eb7a1acfa0cf2d24ed";
  hie = import (fetchTarball {
    url    = "https://github.com/domenkozar/hie-nix/archive/${hieCommit}.tar.gz";
    sha256 = "06ygnywfnp6da0mcy4hq0xcvaaap1w3di2midv1w9b9miam8hdrn";
  }) {};
in {
  # Configure the Nix package manager
  nixpkgs = {
    config.allowUnfree = true;
    # To use the pinned channel, the original package set is thrown
    # away in the overrides:
    config.packageOverrides = oldPkgs: stable // {
      # Store whole unstable channel in case that other modules need
      # it (see emacs.nix for example):
      inherit unstable;

      wallpapers = import ./pkgs/wallpapers.nix;
      pulseaudio-ctl = import pkgs/pulseaudio-ctl.nix;

      kontemplate = unstable.kontemplate;
      mq-cli = unstable.mq-cli;
      vlc = unstable.vlc; # VLC 3.0!
    };
  };

  # Configure additional binary caches (via Cachix)
  nix = {
    binaryCaches = [
      # hie-nix contains the Haskell IDE Engine packaged for NixOS
      "https://hie-nix.cachix.org"
    ];

    binaryCachePublicKeys = [
      "hie-nix.cachix.org-1:EjBSHzF6VmDnzqlldGXbi0RM3HdjfTU3yDRi9Pd0jTY="
    ];

    trustedUsers = [ "root" "vincent" ];
  };

  # ... and declare packages to be installed.
  environment.systemPackages = with pkgs; [
    # Default nixos.* packages:
    alacritty
    binutils-unwrapped
    cargo
    curl
    direnv
    dnsutils
    evince
    exa
    fd
    file
    firefox-unwrapped
    fish
    gcc
    git
    gnumake
    gnupg
    google-cloud-sdk
    gopass
    htop
    hicolor-icon-theme
    i3lock
    iftop
    # Upstream link is down:
    # jetbrains.idea-ultimate
    jq
    kontemplate
    kubernetes
    lispPackages.quicklisp
    lxappearance-gtk3
    manpages
    maven
    msmtp
    mq-cli
    ngrok
    notmuch
    numix-cursor-theme
    numix-gtk-theme
    numix-icon-theme
    offlineimap
    openjdk
    openssl
    openssl.dev
    pass
    pavucontrol
    pkgconfig
    pulseaudio-ctl
    pwgen
    ripgrep
    rustup
    sbcl
    screen
    siege
    spotify
    stdmanpages
    systemd.dev
    tdesktop
    terraform
    tig
    tmux
    tokei
    transmission
    tree
    units
    unzip
    vlc
    xclip
    xfce.xfce4-screenshooter

    # Haskell packages:
    cabal-install
    ghc
    hie.hie82
    hlint
    stack
    stack2nix
    haskellPackages.stylish-haskell
    haskellPackages.yesod-bin
  ];
}
