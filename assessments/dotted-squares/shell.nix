let
  briefcase = import /home/wpcarro/briefcase {};
in briefcase.buildHaskell.shell {
  deps = hpkgs: with hpkgs; [
    hspec
    unordered-containers
  ];
}
