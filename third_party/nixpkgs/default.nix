# This file imports the pinned nixpkgs sets and applies relevant
# modifications, such as our overlays.
#
# Note that the attribute exposed by this (third_party.nixpkgs) is
# "special" in that the fixpoint used as readTree's config parameter
# in //default.nix passes this attribute as the `pkgs` argument to all
# readTree derivations.

{ depot, externalArgs, ... }:

let
  # This provides the sources of nixpkgs. We track both
  # nixos-unstable, and the current stable channel of the latest NixOS
  # release.

  # Tracking nixos-unstable as of 2021-10-04.
  unstableHashes = {
    commit = "14aef06d9b3ad1d07626bdbb16083b83f92dc6c1";
    sha256 = "1rfsfaaa1lbrvhdpdnqg4fg5v7bnal1s8xd1sm66pl2vh0dhjzyg";
  };

  # Tracking nixos-21.05 as of 2021-10-04.
  stableHashes = {
    commit = "7daf35532d2d8bf5e6f7f962e6cd13a66d01a71d";
    sha256 = "0ycyns4vhcd4alnrq5kc813vhxvd1ykwbmd59i1zfmr6j1ksyll0";
  };

  # import the nixos-unstable package set, or optionally use the
  # source (e.g. a path) specified by the `nixpkgsBisectPath`
  # argument. This is intended for use-cases where the depot is
  # bisected against nixpkgs to find the root cause of an issue in a
  # channel bump.
  nixpkgsSrc = externalArgs.nixpkgsBisectPath or (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${unstableHashes.commit}.tar.gz";
    sha256 = unstableHashes.sha256;
  });

  stableNixpkgsSrc = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${stableHashes.commit}.tar.gz";
    sha256 = stableHashes.sha256;
  };

  # Stable package set is imported, but not exposed, to overlay
  # required packages into the unstable set.
  stableNixpkgs = import stableNixpkgsSrc {};

  # Overlay for packages that should come from the stable channel
  # instead (e.g. because something is broken in unstable).
  stableOverlay = self: super: {
    # Nothing picked from stable presently.
  };

  # Overlay to expose the nixpkgs commits we are using to other Nix code.
  commitsOverlay = _: _: {
    nixpkgsCommits = {
      unstable = unstableHashes.commit;
      stable = stableHashes.commit;
    };
  };
in import nixpkgsSrc {
  config.allowUnfree = true;
  config.allowBroken = true;
  overlays = [
    commitsOverlay
    stableOverlay
    depot.third_party.overlays.haskell
    depot.third_party.overlays.emacs
    depot.third_party.overlays.tvl
    depot.third_party.overlays.ecl-static
  ];
}
