{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ThinkPad P14s Gen 5 AMD
  # AMD Ryzen 7 PRO 7840U w/ Radeon 780M Graphics

  # Boot configuration
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ "amdgpu" "evdi" ];
  boot.kernelModules = [ "kvm-amd" "uinput" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ evdi ];

  # Filesystem configuration - Btrfs with subvolumes
  # Note: UUIDs will be regenerated during NixOS installation
  # Update these values after running nixos-generate-config
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7f15bf07-74d7-44b8-8282-87c35c54688d";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7f15bf07-74d7-44b8-8282-87c35c54688d";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/7f15bf07-74d7-44b8-8282-87c35c54688d";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5B90-350D";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  # No swap partition/file currently
  # Consider adding zram for better memory management
  swapDevices = [ ];

  # Enable zram swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # CPU configuration - AMD
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Graphics - AMD Radeon 780M
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # Firmware
  hardware.enableRedistributableFirmware = true;

  # SSD optimization
  services.fstrim.enable = true;

  # Btrfs maintenance
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
