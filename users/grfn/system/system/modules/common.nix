{ config, lib, pkgs, ... }:

let

  depot = import ../../../../.. { };

in

with lib;

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    cleanTmpDir = true;
  };

  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = lib.mkDefault "America/New_York";

  environment.systemPackages = with pkgs; [
    wget
    vim
    zsh
    git
    w3m
    libnotify
    file
    lm_sensors
    dnsutils
    htop
    man-pages
    man-pages-posix
  ];

  documentation.dev.enable = true;
  documentation.man.generateCaches = true;

  services.openssh.enable = true;

  programs.ssh.startAgent = true;

  networking.firewall.enable = mkDefault false;

  users.mutableUsers = true;
  programs.zsh.enable = true;
  environment.pathsToLink = [ "/share/zsh" ];
  users.users.grfn = {
    isNormalUser = true;
    initialPassword = "password";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
    ];
    shell = pkgs.zsh;
  };

  nix = {
    settings.trusted-users = [ "grfn" ];
    distributedBuilds = true;

    gc = {
      automatic = true;
      dates = mkDefault "weekly";
      options = "--delete-older-than 30d";
    };
  };

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  services.pcscd.enable = true;

  services.udev.extraRules = ''
    # UDEV rules for Teensy USB devices
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
  '';
}
