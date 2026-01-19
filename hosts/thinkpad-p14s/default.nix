{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Kernel parameters
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  # Networking
  networking.hostName = "thinkpad-p14s";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # Tailscale VPN
  services.tailscale.enable = true;

  # Firewall exceptions for Tailscale
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Timezone and locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # Japanese fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      font-awesome
      (nerdfonts.override { fonts = [ "Hack" "JetBrainsMono" "FiraCode" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" "Noto Serif CJK JP" ];
        sansSerif = [ "Noto Sans" "Noto Sans CJK JP" ];
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono CJK JP" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Enable Nix flakes and optimization
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # X11 and Wayland
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;

    # Touchpad support
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };
  };

  # Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swayidle
      swaybg
      xwayland
    ];
  };

  # XDG Portal (required for screen sharing on Wayland)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  # Input method - Fcitx5 with Mozc (Japanese)
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      fcitx5-configtool
    ];
  };

  # Power management - TLP for laptops
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Thermal management
  services.thermald.enable = true;

  # Thunderbolt support
  services.hardware.bolt.enable = true;

  # Wake-on-Wireless-LAN
  systemd.services.wowlan = {
    description = "Enable Wake-on-Wireless-LAN";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iw}/bin/iw phy0 wowlan enable magic-packet";
    };
  };

  # Printing support (CUPS)
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint ];

  # Scanner support
  hardware.sane.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    usbutils
    pciutils
  ];

  # Yubikey support (optional)
  services.udev.packages = with pkgs; [ yubikey-personalization ];
  services.pcscd.enable = true;

  # Enable dconf (required for GTK apps)
  programs.dconf.enable = true;

  # User account
  users.users.susiyaki = {
    isNormalUser = true;
    description = "susiyaki";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
      "docker"
      "scanner"
      "lp"
    ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJk87yynVkYEc23+7hM/4/aZ+7yAeZWETcwXUMVRf/jFISb3ONA54NpLHWmsNuJ1+UAwCvq2/+EjjU7zZ2iee2s= #ssh.id - @susiyaki.dev"
    ];
  };

  # Docker support
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Polkit for authentication
  security.polkit.enable = true;

  # Allow unfree packages (for Discord, Spotify, etc.)
  nixpkgs.config.allowUnfree = true;

  # SSH server configuration
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Only allow key-based authentication
      PubkeyAuthentication = true;
      # Security hardening
      X11Forwarding = false;
      KbdInteractiveAuthentication = false;
      # Only allow connections from Tailscale network
      # ListenAddress can be configured after getting Tailscale IP
    };
  };

  # This value determines the NixOS release
  system.stateVersion = "24.05";
}
