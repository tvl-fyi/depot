{ depot, pkgs, ... }:

depot.nix.buildGo.external {
  path = "github.com/jbenet/go-context";

  src = pkgs.fetchFromGitHub {
    owner = "jbenet";
    repo = "go-context";
    rev = "d14ea06fba99483203c19d92cfcd13ebe73135f4";
    sha256 = "0q91f5549n81w3z5927n4a1mdh220bdmgl42zi3h992dcc4ls0sl";
  };

  deps = with depot.third_party; [
    gopkgs."golang.org".x.net.context
  ];
}
