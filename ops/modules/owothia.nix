# Run the owothia IRC bot.
{ depot, config, lib, pkgs, ... }:

let
  cfg = config.services.depot.owothia;
  description = "owothia - i'm a service owo";
in
{
  options.services.depot.owothia = {
    enable = lib.mkEnableOption description;

    secretsFile = lib.mkOption {
      type = lib.types.str;
      description = "File path from which systemd should read secrets";
      default = config.age.secretsDir + "/owothia";
    };

    owoChance = lib.mkOption {
      type = lib.types.int;
      description = "How likely is owo?";
      default = 200;
    };

    ircServer = lib.mkOption {
      type = lib.types.str;
      description = "IRC server hostname";
    };

    ircPort = lib.mkOption {
      type = lib.types.int;
      description = "IRC server port";
    };

    ircIdent = lib.mkOption {
      type = lib.types.str;
      description = "IRC username";
      default = "owothia";
    };

    ircChannels = lib.mkOption {
      type = with lib.types; listOf str;
      description = "IRC channels to join";
      default = [ "#tvl" ];
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.owothia = {
      inherit description;
      script = "${depot.fun.owothia}/bin/owothia";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        EnvironmentFile = cfg.secretsFile;
      };

      environment = {
        OWO_CHANCE = toString cfg.owoChance;
        IRC_SERVER = cfg.ircServer;
        IRC_PORT = toString cfg.ircPort;
        IRC_IDENT = cfg.ircIdent;
        IRC_CHANNELS = builtins.toJSON cfg.ircChannels;
      };
    };
  };
}
