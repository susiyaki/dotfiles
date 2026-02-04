{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../profiles/cli.nix
    ../profiles/dev.nix
    ../profiles/desktop.nix
    ../modules/linux/sway
    ../modules/linux/waybar
    ../modules/linux/xremap
    ../modules/linux/wofi
    ../modules/linux/wireplumber-watchdog
    # ../modules/linux/whisper-overlay
  ];

  # Standalone home-manager requires these
  home.username = "susiyaki";
  home.homeDirectory = "/home/susiyaki";

  # Linux-specific packages (keep only what's truly host-specific)
  home.packages = with pkgs; [
    # SSH key management
    keychain # SSH agent manager with keyring integration

    # Fonts
    skkDictionaries.l # SKK dictionary for skkeleton
    (pkgs.callPackage ../pkgs/ttf-hackgen { }) # HackGen Japanese programming font
  ];

  # Sway configuration
  my.desktop.sway = {
    enable = true;
    fontSize = 14;
    # terminal = "alacritty"; # This is the default
  };

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

    # Force Electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
  };

  # Linux-specific fish aliases
  programs.fish.shellAliases = {
    # System management
    reflectorjp = "sudo reflector --country 'Japan' --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist";
    nix-switch = "sudo nixos-rebuild switch --flake ~/dotfiles#thinkpad-p14s";
  };

  # Chrome/Electron Wayland Flags
  home.file.".config/chrome-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
    --wayland-text-input-version=3
  '';

  home.file.".config/electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
    --enable-wayland-ime
    --wayland-text-input-version=3
  '';

  # Linux-specific shell config
  programs.fish.shellInit = ''
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

  # Mouse Cursor
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

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
    program = "${pkgs.fish}/bin/fish"
    args = ["-l", "-c", "tmux new-session -A -s main"]
  '';

  # Set Linux-specific alacritty config as default
  home.file.".config/alacritty/alacritty.toml".text = ''
    [general]
    import = ["alacritty.linux.toml"]
  '';

  # tmux configuration
  programs.tmux.extraConfig = ''
    # AI Assistant (Linux)
    set-environment -g AI_ASSISTANT "gemini"

    # Shell configuration (Nix-managed fish)
    set-option -g default-shell ${pkgs.fish}/bin/fish
    set-option -g default-command ${pkgs.fish}/bin/fish

    # Copy/Paste configuration (Wayland)
    # "y" でヤンク (wl-copy)
    set -s copy-command 'wl-copy'
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

    # "Y" で行ヤンク
    bind -T copy-mode-vi Y send -X copy-line

    # "p"でペースト (wl-paste)
    bind p run "tmux set-buffer \"$(wl-paste)\"; tmux paste-buffer"
  '';

  home.file.".config/tmux/tmux-base.conf".source = ../config/tmux/tmux-base.conf;
  home.file.".config/tmux/scripts" = {
    source = ../config/tmux/scripts;
    recursive = true;
  };


  # Swaylock configuration
  home.file.".config/swaylock/config".source = ../config/swaylock/config;

  # Wlogout configuration
  home.file.".config/wlogout".source = ../config/wlogout;

  # Thunar volume manager configuration
  home.file.".config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml".source = ../config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml;

  # Neovim skkeleton dictionary path
  home.file.".config/nvim/lua/skkeleton-dict-path.lua".text = ''
    return "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L"
  '';

  # Fcitx5 configuration (manually managed part, if needed, though NixOS module handles most)
  # Linking profile to ensure correct input method order (keyboard-us first, then skk)
  home.file.".config/fcitx5/profile".source = ../config/fcitx5/profile;
  home.file.".config/fcitx5/conf/skk.conf".source = ../config/fcitx5/conf/skk.conf;

  # libskk rules for custom keybindings
  home.file.".config/libskk".source = ../config/libskk;

  # Claude Code configuration (merge common + linux settings)
  home.file.".claude/settings.json".text =
    let
      commonSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.common.json);
      linuxSettings = builtins.fromJSON (builtins.readFile ../config/claude/settings.linux.json);
      mergedSettings = pkgs.lib.recursiveUpdate commonSettings linuxSettings;
    in
    builtins.toJSON mergedSettings;

  # Gemini CLI configuration (merge common + linux settings)
  home.file.".gemini/settings.json" = {
    text =
      let
        commonSettings = builtins.fromJSON (builtins.readFile ../config/gemini/settings.common.json);
        linuxSettings = builtins.fromJSON (builtins.readFile ../config/gemini/settings.linux.json);
        mergedSettings = pkgs.lib.recursiveUpdate commonSettings linuxSettings;
      in
      builtins.toJSON mergedSettings;
    force = true;
  };
}
