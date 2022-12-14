{ pkgs, depot, lib, ... }:

let
  bins =
    depot.nix.getBins pkgs.s6-portable-utils [ "s6-ln" "s6-cat" "s6-echo" "s6-mkdir" "s6-test" "s6-touch" "s6-dirname" ]
    // depot.nix.getBins pkgs.lr [ "lr" ]
  ;
  crate-advisories = "${depot.third_party.rustsec-advisory-db}/crates";

  check-security-advisory = depot.nix.writers.rustSimple
    {
      name = "parse-security-advisory";
      dependencies = [
        depot.third_party.rust-crates.toml
        depot.third_party.rust-crates.semver
      ];
    }
    (builtins.readFile ./check-security-advisory.rs);

  # $1 is the directory with advisories for crate $2 with version $3
  check-crate-advisory = depot.nix.writeExecline "check-crate-advisory" { readNArgs = 3; } [
    "pipeline"
    [ bins.lr "-0" "-t" "depth == 1" "$1" ]
    "forstdin"
    "-0"
    "-Eo"
    "0"
    "advisory"
    "if"
    [ depot.tools.eprintf "advisory %s\n" "$advisory" ]
    check-security-advisory
    "$advisory"
    "$3"
  ];

  # Run through everything in the `crate-advisories` repository
  # and check whether we can parse all the advisories without crashing.
  test-parsing-all-security-advisories = depot.nix.runExecline "check-all-our-crates" { } [
    "pipeline"
    [ bins.lr "-0" "-t" "depth == 1" crate-advisories ]
    "if"
    [
      # this will succeed as long as check-crate-advisory doesn’t `panic!()` (status 101)
      "forstdin"
      "-0"
      "-E"
      "-x"
      "101"
      "crate_advisories"
      check-crate-advisory
      "$crate_advisories"
      "foo"
      "0.0.0"
    ]
    "importas"
    "out"
    "out"
    bins.s6-touch
    "$out"
  ];
in

depot.nix.readTree.drvTargets {
  inherit
    check-crate-advisory
    test-parsing-all-security-advisories
    ;
}
