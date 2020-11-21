{ config ? throw "not a readTree target", ... }:

let
  depot = import <depot> {};
  pkgs = import <nixpkgs> {};

  depotPath = depot.users.multi.whitby.depot;
in

{
  programs = {
    home-manager = {
      enable = true;
      path = toString pkgs.home-manager.src;
    };

    bash = {
      enable = true;
      initExtra = ''
        bind '"\e[5~":history-search-backward'
        bind '"\e[6~":history-search-forward'

        PS1="[\\u@\\h:\\w]\\\$ "

        _Z_CMD=d
        source ~/.z.sh
      '';
    };

    tmux = {
      enable = true;
      terminal = "tmux-256color";
      escapeTime = 50;
      extraConfig = ''
        bind-key -n C-S-Left swap-window -t -1
        bind-key -n C-S-Right swap-window -t +1
      '';
    };

    vim = {
      enable = true;
      extraConfig = "set mouse=";
    };
  };

  home.sessionVariables = {
    NIX_PATH =
      "nixpkgs=${depot.third_party.nixpkgsSrc}:" +
      "depot=${depotPath}";
    HOME_MANAGER_CONFIG = "${depotPath}/users/multi/whitby/home-manager.nix";
    EDITOR = "vim";
  };

  home.packages = [
    pkgs.lsof
    pkgs.strace
    pkgs.file
    pkgs.pciutils
  ] ++ (import ../pkgs { inherit pkgs; });

  home.file = {
    z = {
      source = builtins.fetchurl "https://raw.githubusercontent.com/rupa/z/9f76454b32c0007f20b0eae46d55d7a1488c9df9/z.sh";
      target = ".z.sh";
    };
  };

  home.stateVersion = "20.03";
}
