{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/archlinux/sway
    ../modules/archlinux/waybar
  ];

  # Standalone home-manager requires these
  home.username = "susiyaki";
  home.homeDirectory = "/home/susiyaki";

  # Allow unfree packages (Discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # Linux-specific packages
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    grim
    slurp
    wf-recorder  # Screen recording
    wev          # Wayland event viewer
    wl-mirror    # Screen mirroring
    wlr-randr    # Display configuration

    # Display
    brightnessctl
    nwg-displays
    kanshi       # Autorandr for Wayland

    # Notification
    libnotify
    swaynotificationcenter  # Sway notification center

    # Bluetooth
    blueman

    # Audio
    pavucontrol
    playerctl    # Media player control

    # Launcher
    wofi
    rofi         # Launcher (Wayland support built-in)

    # File manager
    thunar
    tumbler      # Thumbnail generator for Thunar
    gvfs         # Virtual filesystem (for Thunar)
    xfce.thunar-volman  # Removable media manager
    xfce.thunar-archive-plugin  # Archive support

    # Fonts (system-level fonts are in system config, but keeping here for reference)
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome

    # Applications
    firefox
    discord
    celluloid    # Video player
    mpv          # Lightweight video player
    imv          # Image viewer for Wayland

    # Development
    android-tools
    dbeaver-bin
    postman      # API development

    # Utilities
    wdisplays    # Display configuration GUI
    pamixer      # PulseAudio mixer
    networkmanagerapplet  # Network Manager GUI
    xarchiver    # Archive manager
    gnome-calculator

    # Screenshots
    swappy       # Screenshot editor

    # System monitoring
    btop         # Better htop
    nvtopPackages.amd  # GPU monitoring for AMD

    # GTK theme
    adwaita-icon-theme
    gnome-themes-extra
    gtk-engine-murrine
    lxappearance  # GTK theme switcher
  ];

  # Linux-specific environment variables
  home.sessionVariables = {
    # Android SDK (Linux)
    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_SDK_ROOT = "$HOME/Android/Sdk";

    # Wayland-specific
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # GTK theme
    GTK_THEME = "Adwaita:dark";
  };

  # Linux-specific fish aliases
  programs.fish.shellAliases = {
    # System management
    reflectorjp = "sudo reflector --country 'Japan' --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist";
    hm-switch = "home-manager switch --flake ~/dotfiles-new#susiyaki@thinkpad-p14s";

    # Common shortcuts
    ls = "eza --icons";
    ll = "eza -l --icons";
    la = "eza -la --icons";
    cat = "bat";

    # Git shortcuts (in addition to git aliases)
    g = "git";
    gs = "git status";
    gd = "git diff";

    # Clipboard
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  # Linux-specific shell config
  programs.fish.shellInit = ''
    # mise (Linux)
    if test -f "$HOME/.local/bin/mise"
      $HOME/.local/bin/mise activate fish | source
    end

    # SSH agent
    if test -z "$SSH_AUTH_SOCK"
      eval (ssh-agent -c) > /dev/null
    end
  '';

  # GTK configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Noto Sans CJK JP 11";
      package = pkgs.noto-fonts-cjk-sans;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt configuration (for consistency with GTK)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/github/id_rsa";
        user = "git";
      };
    };
  };

  # Alacritty configuration
  home.file.".config/alacritty/alacritty-base.toml".source = ../config/alacritty/alacritty-base.toml;
  home.file.".config/alacritty/alacritty.linux.toml".source = ../config/alacritty/alacritty.linux.toml;

  # Set Linux-specific alacritty config as default
  home.file.".config/alacritty/alacritty.toml".text = ''
    [general]
    import = ["alacritty.linux.toml"]
  '';

  # Swaylock configuration
  home.file.".config/swaylock/config".source = ../config/swaylock/config;

  # Wlogout configuration
  home.file.".config/wlogout".source = ../config/wlogout;
}
