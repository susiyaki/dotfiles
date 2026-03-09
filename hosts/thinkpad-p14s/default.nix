{ config, pkgs, lib, inputs, ... }:

let
  addresses = import ../../config/network/addresses.nix;
  nasIp = addresses.tailscale.nas;
in
{
  imports = [
    ./hardware.nix
  ] ++ lib.optional true ./displaylink.nix;

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
    "amdgpu.gpu_recovery=1"
  ];

  # Increase inotify limits for file watching
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512;
  };

  # Networking
  networking.hostName = "thinkpad-p14s";
  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = false;
      scanRandMacAddress = false;
    };
  };
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      22000 # Syncthing sync (tailscale only)
    ];
    allowedUDPPorts = [
      22000 # Syncthing QUIC (tailscale only)
      21027 # Syncthing local discovery (tailscale only)
    ];
  };
  networking.firewall.allowedTCPPortRanges = [
    { from = 1714; to = 1764; } # KDE Connect
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 1714; to = 1764; } # KDE Connect
    { from = 60000; to = 61000; }
  ];

  # Tailscale VPN
  services.tailscale.enable = true;

  # Keep network/session alive when laptop lid is closed
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Do not fully trust tailscale0; only allow specific service ports above.
  networking.firewall.trustedInterfaces = [ ];

  # SMB mount for Synology docker share (auto-mount on access)
  # Define explicit systemd mount/automount units to avoid generator timing issues
  # during switch-to-configuration.
  boot.supportedFilesystems = [ "cifs" ];
  systemd.mounts = [
    {
      description = "NAS docker share";
      what = "//${nasIp}/docker";
      where = "/mnt/nas-docker";
      type = "cifs";
      options = lib.concatStringsSep "," [
        "credentials=/etc/nixos/secrets/smb-docker-cred"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
        "vers=3.0"
        "_netdev"
        "nofail"
        "noauto"
        "x-systemd.mount-timeout=10s"
      ];
    }
  ];
  systemd.automounts = [
    {
      where = "/mnt/nas-docker";
      wantedBy = [ "multi-user.target" ];
      automountConfig.TimeoutIdleSec = "120";
    }
  ];
  systemd.tmpfiles.rules = [
    "d /mnt/nas-docker 0775 root users -"
  ];

  systemd.services.network-startup-snapshot = {
    description = "Capture NetworkManager startup state";
    after = [ "NetworkManager.service" ];
    wants = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/sleep 15
      out=/tmp/network-startup.log
      {
        echo "=== $(date --iso-8601=seconds) ==="
        ${pkgs.networkmanager}/bin/nmcli general status || true
        echo
        ${pkgs.networkmanager}/bin/nmcli device status || true
        echo
        ${pkgs.networkmanager}/bin/nmcli -f NAME,UUID,TYPE,AUTOCONNECT,DEVICE connection show || true
        echo
        ${pkgs.systemd}/bin/journalctl -b -u NetworkManager --no-pager | ${pkgs.ripgrep}/bin/rg -i 'wlp2s0|NoeHouse_5G|autoconnect|unmanaged|unavailable|supplicant|secret' || true
      } > "$out"
    '';
  };

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
    # Add nix-community cache to reduce local builds (e.g. deno).
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
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

      # WiFi power saving off to prevent random disconnects (ath11k)
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  # Thermal management
  services.thermald.enable = true;

  # Thunderbolt support
  services.hardware.bolt.enable = true;

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
    whisper-cpp
    stdenv.cc.cc.lib
  ];

  # Yubikey support (optional)

  # Enable dconf (required for GTK apps)
  programs.dconf.enable = true;

  # KDE Connect (phone integration)
  programs.kdeconnect.enable = true;

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
