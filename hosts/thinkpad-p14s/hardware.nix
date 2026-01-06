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
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystem configuration - Btrfs
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fbc0c8fd-f601-4135-a49b-105ad12b5dd7";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
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
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Graphics - AMD Radeon 780M
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  # For 32-bit applications
  hardware.graphics.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

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
