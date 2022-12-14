{ depot, pkgs, ... }:

depot.nix.buildGo.external {
  path = "github.com/kevinburke/ssh_config";

  src = pkgs.fetchFromGitHub {
    owner = "kevinburke";
    repo = "ssh_config";
    rev = "01f96b0aa0cdcaa93f9495f89bbc6cb5a992ce6e";
    sha256 = "1bxfjkjl3ibzdkwyvgdwawmd0skz30ah1ha10rg6fkxvj7lgg4jz";
  };
}
