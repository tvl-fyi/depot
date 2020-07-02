{ config, lib, pkgs, ... }:
{
  imports = [
    ../modules/common.nix
    ../modules/reusable/battery.nix
    ../modules/tvl.nix
  ];

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "chupacabra";

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  laptop.onLowBattery = {
    enable = true;
    action = "hibernate";
    thresholdPercentage = 5;
  };

  boot.initrd.luks.devices."cryptswap".device = "/dev/disk/by-uuid/3b6e2fd4-bfe9-4392-a6e0-4f3b3b76e019";

  boot.kernelParams = [ "acpi_rev_override" ];
  services.thermald.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  # Intel-only graphics
  hardware.nvidiaOptimus.disable = true;
  boot.blacklistedKernelModules = [ "nouveau" "intel" ];
  services.xserver.videoDrivers = [ "intel" ];

  # Nvidia Optimus (hybrid) - currently not working
  # services.xserver.videoDrivers = [ "intel" "nvidia" ];
  # boot.blacklistedKernelModules = [ "nouveau" "bbswitch" ];
  # boot.extraModulePackages = [ pkgs.linuxPackages.nvidia_x11 ];
  # hardware.bumblebee.enable = true;
  # hardware.bumblebee.pmMethod = "none";

  systemd.services.disable-usb-autosuspend = {
    description = "Disable USB autosuspend";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = { Type = "oneshot"; };
    unitConfig.RequiresMountsFor = "/sys";
    script = ''
      echo -1 > /sys/module/usbcore/parameters/autosuspend
    '';
  };

  # From hardware-configuration.nix

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/c2fc7ce7-a45e-48a1-8cde-be966ef601db";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3492-9E3A";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/caa7e2ff-475b-4024-b29e-4f88f733fc4c"; }
    ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  # from nixos-hardware TODO sort this around
  services.tlp.enable = true;
  boot.kernel.sysctl."vm.swappiness" = 1;
  services.fstrim.enable = lib.mkDefault true;

  # Intel cpu stuff
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
