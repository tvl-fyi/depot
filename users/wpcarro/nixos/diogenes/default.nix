{ depot, pkgs, ... }:
{ ... }:

let
  inherit (depot.users.wpcarro) keys;
in {
  imports = [
    "${depot.path}/ops/modules/quassel.nix"
    (pkgs.path + "/nixos/modules/virtualisation/google-compute-image.nix")
  ];

  networking = {
    hostName = "diogenes";
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  # Use the TVL binary cache
  tvl.cache.enable = true;

  # Use 100G volume for /nix
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/62396bde-9002-4025-83eb-2a6c731b7adc";
    fsType = "ext4";
  };

  users = {
    mutableUsers = true;
    users = {
      wpcarro = {
        isNormalUser = true;
        extraGroups = [ "wheel" "quassel" ];
        openssh.authorizedKeys.keys = keys.all;
        shell = pkgs.fish;
      };
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      email = "wpcarro@gmail.com";

      certs."quassel.wpcarro.dev" = {
        email = "wpcarro@gmail.com";
        webroot = "/var/lib/acme/challenge-quassel";
        group = "quassel";
      };
    };

    sudo.wheelNeedsPassword = false;
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  environment.systemPackages = with pkgs; [
    dig
    fd
    fzf
    mkpasswd
    ripgrep
    tldr
    tree
    vim
  ];

  services = {
    depot.automatic-gc = {
      enable = true;
      interval = "1 hour";
      diskThreshold = 16; # GiB
      maxFreed = 10; # GiB
      preserveGenerations = "14d";
    };

    depot.quassel = {
      enable = true;
      acmeHost = "quassel.wpcarro.dev";
      bindAddresses = [
        "0.0.0.0"
      ];
    };

    journaldriver = {
      enable = true;
      logStream = "home";
      googleCloudProject = "wpcarros-infrastructure";
      applicationCredentials = "/etc/gcp/key.json";
    };

    nginx = {
      enable = true;
      enableReload = true;

      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      # for journaldriver
      commonHttpConfig = ''
        log_format json_combined escape=json
        '{'
            '"remote_addr":"$remote_addr",'
            '"method":"$request_method",'
            '"host":"$host",'
            '"uri":"$request_uri",'
            '"status":$status,'
            '"request_size":$request_length,'
            '"response_size":$body_bytes_sent,'
            '"response_time":$request_time,'
            '"referrer":"$http_referer",'
            '"user_agent":"$http_user_agent"'
        '}';

        access_log syslog:server=unix:/dev/log,nohostname json_combined;
      '';

      virtualHosts = {
        "wpcarro.dev" = {
          addSSL = true;
          enableACME = true;
          root = depot.users.wpcarro.website;
        };
        "blog.wpcarro.dev" = {
          addSSL = true;
          enableACME = true;
          root = depot.users.wpcarro.website.blog;
        };
      };
    };
  };

  system.stateVersion = "21.11";
}
