{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # Allow unfree packages (Discord, 1Password, etc.)
  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Kernel - LTS for DisplayLink stability
  # DisplayLink's evdi module has compatibility issues with kernel 6.12+
  # Using LTS kernel (6.6.x) for reliable DisplayLink support
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Kernel parameters
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  # Increase inotify limits for file watching
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512;
  };

  # Networking
  networking.hostName = "thinkpad-p14s";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 60000; to = 61000; }
  ];

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

  # Input Method (Fcitx5 + SKK)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-skk
        fcitx5-gtk
      ];
      waylandFrontend = true;
    };
  };

  # Japanese fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      font-awesome
      nerd-fonts.hack
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

    # DisplayLink support for external monitors (requires manual download due to EULA).
    # Uncomment after downloading: https://www.synaptics.com/products/displaylink-usb-graphics-software-ubuntu-62
    videoDrivers = [
      "modesetting"
    ];
  };

  # Display manager (greetd with agreety)
  services.greetd = {
    enable = true;
    settings = {
      # Use agreety as the greeter.
      # agreety will prompt for username and password,
      # and then execute the specified command.
      # In this case, it launches the user's default shell.
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd sway";
        user = "greeter"; # It is common practice to run greeters as a dedicated 'greeter' user
      };
    };
  };

  # Ensure that the greetd PAM service is configured.
  # This allows greetd to authenticate users.
  security.pam.services.greetd = {
    allowNullPassword = lib.mkForce false;
    startSession = true;
  };

  # Enable sway program at the system level so greetd can find it
  programs.sway.enable = true;

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      disableWhileTyping = true;
    };
  };

  # XDG Portal (required for screen sharing on Wayland)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [
          "wlr"
          "gtk"
        ];
      };
    };
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

      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  # Thermal management
  services.thermald.enable = true;

  # Thunderbolt support
  services.hardware.bolt.enable = true;

  # Wake-on-Wireless-LAN
  systemd.services.wowlan = {
    description = "Enable Wake-on-Wireless-LAN";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [ iw gawk gnugrep ];
    script = ''
      # Find the phy associated with wlp2s0
      PHY=$(iw dev wlp2s0 info | grep wiphy | awk '{print "phy"$2}')
      if [ -n "$PHY" ]; then
        iw $PHY wowlan enable magic-packet
        echo "Enabled WoWLAN on $PHY (wlp2s0)"
      else
        echo "Could not find phy for wlp2s0"
        exit 1
      fi
    '';
  };

  # uinput device access (for game controllers, remote desktop, etc.)
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", TAG+="uaccess"
  '';

  # Printing support (CUPS)
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ gutenprint ];

  # Scanner support
  hardware.sane.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    gcc
    gnumake
    gnupg
    git
    wget
    curl
    htop
    usbutils
    pciutils
    mosh
    zip
    unzip
  ];

  # Yubikey support (optional)
  services.udev.packages = with pkgs; [ yubikey-personalization ];
  services.pcscd.enable = true;

  # Enable dconf (required for GTK apps)
  programs.dconf.enable = true;

  # Enable nix-ld for running unpatched binaries (e.g. from mise, npm)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    # Add more libraries here as needed for specific tools
  ];

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "susiyaki" ];
  };

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
