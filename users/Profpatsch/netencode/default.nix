{ pkgs, depot, ... }:

let
  imports = {
    inherit (depot.users.Profpatsch)
      writers;
  };

  version-check = pkgs.buildRustCrate {
    pname = "version-check";
    version = "0.9.2";
    crateName = "version-check";
    sha256 = "1vwvc1mzwv8ana9jv8z933p2xzgj1533qwwl5zr8mi89azyhq21v";
  };
  memchr = pkgs.buildRustCrate {
    pname = "memchr";
    version = "2.3.3";
    crateName = "memchr";
    sha256 = "1ivxvlswglk6wd46gadkbbsknr94gwryk6y21v64ja7x4icrpihw";
  };
  nom = pkgs.buildRustCrate {
    pname = "nom";
    version = "5.1.1";
    crateName = "nom";
    sha256 = "1gb4r6mjwd645jqh02nhn60i7qkw8cgy3xq1r4clnmvz3cmkv1l0";
    dependencies = [ memchr ];
    buildDependencies = [ version-check ];
    features = [ "std" "alloc" ];
  };

  netencode-rs-common = tests: imports.writers.rustSimpleLib {
    name = "netencode";
    dependencies = [ nom ];
    buildTests = tests;
    release = false;
    verbose = true;
  } (builtins.readFile ./netencode.rs);

  netencode-rs-tests = netencode-rs-common true;

  netencode-rs = netencode-rs-common false;

  gen = import ./netencode.nix;

  cfg-if = pkgs.buildRustCrate {
    pname = "cfg-if";
    version = "1.0.0";
    crateName = "cfg-if";
    sha256 = "1fzidq152hnxhg4lj6r2gv4jpnn8yivp27z6q6xy7w6v0dp6bai9";
  };

  log = pkgs.buildRustCrate {
    pname = "log";
    version = "0.4.11";
    crateName = "log";
    sha256 = "0m6xhqxsps5mgd7r91g5mqkndbh8zbjd58p7w75r330zl4n40l07";
    dependencies = [ cfg-if ];
  };

  serde_derive = pkgs.buildRustCrate {
    pname = "serde";
    version = "1.0.118";
    crateName = "serde";
    sha256 = "1kbi2csphq8m4z77fpd6v8jih10j7867wniqnlxnk308mrnxi4r2";
  };

  serde = pkgs.buildRustCrate {
    pname = "serde";
    version = "1.0.118";
    crateName = "serde";
    sha256 = "1kbi2csphq8m4z77fpd6v8jih10j7867wniqnlxnk308mrnxi4r2";
    features = [ "std" ];
  };

  mustache = pkgs.buildRustCrate {
    pname = "mustache";
    version = "0.9.0";
    crateName = "mustache";
    sha256 = "1zgl8l15i19lzp90icgwyi6zqdd31b9vm8w129f41d1zd0hs7ayq";
    dependencies = [ log serde ];
  };

  netencode-mustache = imports.writers.rustSimple {
    name = "netencode_mustache";
    dependencies = [
      netencode-rs
      mustache
    ];
  } (builtins.readFile ./netencode-mustache.rs);


in {
  inherit
   netencode-rs
   netencode-rs-tests
   netencode-mustache
   gen
   ;
}
