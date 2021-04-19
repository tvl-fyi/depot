{ pkgs, lib, config, ... }:

let
  laptopKeyboardId = "5";
in

{
  imports = [
    ../platforms/linux.nix
    ../modules/common.nix
  ];

  # for when hacking
  programs.home-manager.enable = true;
  home.stateVersion = "20.03";

  system.machine = {
    wirelessInterface = "wlp0s20f3";
    i3FontSize = 9;
  };

  home.packages = with pkgs; [
    zoom-us
    slack
    mysql
    graphviz
    mypaint
    xdot

    (discord.override rec {
      version = "0.0.14";
      src = fetchurl {
        url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "1rq490fdl5pinhxk8lkfcfmfq7apj79jzf3m14yql1rc9gpilrf2";
      };
    })

    steam

    (awscli2.overridePythonAttrs (oldAttrs: {
      postPatch = ''
        substituteInPlace setup.py \
          --replace 'colorama>=0.2.5,<0.4.4' 'colorama'  \
          --replace 'wcwidth<0.2.0' 'colorama' \
          --replace 'cryptography>=2.8.0,<=2.9.0' 'cryptography' \
          --replace 'docutils>=0.10,<0.16' 'docutils' \
          --replace 'ruamel.yaml>=0.15.0,<0.16.0' 'ruamel.yaml'
      '';
    }))
  ];

  systemd.user.services.laptop-keyboard = {
    Unit = {
      Description = "Swap caps+escape and alt+super, but only on the built-in laptop keyboard";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = (
        "${pkgs.xorg.setxkbmap}/bin/setxkbmap "
          + "-device ${laptopKeyboardId} "
          + "-option caps:swapescape "
          + "-option compose:ralt "
          + "-option altwin:swap_alt_win"
      );
    };
  };

  xsession.windowManager.i3.config.keybindings.F9 = "exec lock";
}