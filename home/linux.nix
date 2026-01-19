{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/linux/sway
    ../modules/linux/waybar
    ../modules/linux/xremap
    ../modules/linux/wofi
    ../modules/linux/wireplumber-watchdog
    ../modules/linux/speak-to-ai/archlinux.nix  # Arch Linux用（NixOSではdefault.nixを使用）
  ];

  # Standalone home-manager requires these
  home.username = "susiyaki";
  home.homeDirectory = "/home/susiyaki";

  # Allow unfree packages (Discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # Linux-specific packages
  home.packages = with pkgs; [
    # SSH key management
    keychain     # SSH agent manager with keyring integration

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

    # fzf - Uses Wayland's wl-copy
    FZF_DEFAULT_OPTS = "--preview 'bat --color=always --theme=gruvbox-dark --style=numbers,header --line-range :100 {}' --bind 'ctrl-y:execute: echo {} | wl-copy' --bind 'ctrl-o:execute: tmux new-window nvim {}'";
  };

  # Linux-specific fish aliases
  programs.fish.shellAliases = {
    # System management
    reflectorjp = "sudo reflector --country 'Japan' --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist";
    nix-switch = "home-manager switch --flake ~/dotfiles#susiyaki@thinkpad-p14s";

    # Common shortcuts
    ls = "eza --icons";
    ll = "eza -l --icons";
    la = "eza -la --icons";
    cat = "bat";

    # Git shortcuts (in addition to git aliases)
    g = "git";
    gs = "git status";
    gd = "git diff";
  };

  # Linux-specific shell config
  programs.fish.shellInit = ''
    # mise (Linux)
    if test -f "$HOME/.local/bin/mise"
      $HOME/.local/bin/mise activate fish | source
    end

    # Keychain - SSH key management
    if type -q keychain
      if not set -q TMUX
        # Outside tmux: start keychain (may prompt for password)
        keychain --quick --quiet --eval ~/.ssh/github/id_rsa | source
      else
        # Inside tmux: only load environment variables (no password prompt)
        if test -f "$HOME/.keychain/$HOSTNAME-fish"
          source "$HOME/.keychain/$HOSTNAME-fish"
        end
      end
    end
  '';

  # SSH agent is managed by keychain (see programs.fish.shellInit)

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

  # Generate alacritty.linux.toml with dynamic username
  home.file.".config/alacritty/alacritty.linux.toml".text = ''
    # ============================================================
    # Alacritty - Linux Specific Configuration
    # ============================================================

    [general]
    import = ["alacritty-base.toml"]

    # Override shell path for Linux (Nix)
    [terminal.shell]
    program = "${config.home.homeDirectory}/.nix-profile/bin/fish"
    args = ["-l", "-c", "tmux new-session -A -s main"]
  '';

  # Set Linux-specific alacritty config as default
  home.file.".config/alacritty/alacritty.toml".text = ''
    [general]
    import = ["alacritty.linux.toml"]
  '';

  # tmux configuration
  home.file.".config/tmux/tmux-base.conf".source = ../config/tmux/tmux-base.conf;

  # Generate tmux.conf with dynamic username
  home.file.".config/tmux/tmux.conf".text = ''
    # Load base configuration
    source-file ~/.config/tmux/tmux-base.conf

    # Shell configuration (Nix-managed fish)
    set-option -g default-shell ${config.home.homeDirectory}/.nix-profile/bin/fish
    set-option -g default-command ${config.home.homeDirectory}/.nix-profile/bin/fish

    # Copy/Paste configuration (Wayland)
    # "y" でヤンク (wl-copy)
    set -s copy-command 'wl-copy'
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

    # "Y" で行ヤンク
    bind -T copy-mode-vi Y send -X copy-line

    # "p"でペースト (wl-paste)
    bind p run "tmux set-buffer \"$(wl-paste)\"; tmux paste-buffer"
  '';

  # Swaylock configuration
  home.file.".config/swaylock/config".source = ../config/swaylock/config;

  # Wlogout configuration
  home.file.".config/wlogout".source = ../config/wlogout;

  # Claude Code configuration (merge common + archlinux settings)
  home.file.".claude/settings.json".text =
    let
      commonSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.common.json);
      archlinuxSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.archlinux.json);
      mergedSettings = pkgs.lib.recursiveUpdate commonSettings archlinuxSettings;
    in
      builtins.toJSON mergedSettings;
}
