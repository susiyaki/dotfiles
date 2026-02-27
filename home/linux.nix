{ config, pkgs, lib, android-nixpkgs, ... }:

let
  androidSdk = android-nixpkgs.sdk.${pkgs.stdenv.system} (
    sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
      build-tools-34-0-0
      platform-tools
      platforms-android-34
      emulator
    ]
  );
in
{
  imports =
    [
      ./common.nix
      ../profiles/cli.nix
      ../profiles/dev.nix
      ../profiles/desktop.nix
      ../modules/linux/sway
      ../modules/linux/waybar
      ../modules/linux/xremap
      ../modules/linux/wofi
      ../modules/linux/wireplumber-watchdog
      ../modules/linux/syncthing
    ]
    ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;

  # Standalone home-manager user/homeDirectory should live in home/local.nix

  # Syncthing configuration
  my.services.syncthing.enable = true;

  # Linux-specific packages (keep only what's truly host-specific)
  home.packages = with pkgs; [
    # SSH key management
    keychain # SSH agent manager with keyring integration
    # Network tools
    iw
    ethtool

    # Fonts
    skkDictionaries.l # SKK dictionary for skkeleton
    (pkgs.callPackage ../pkgs/ttf-hackgen { }) # HackGen Japanese programming font

    # Android SDK
    androidSdk
  ];

  # Symlink Android SDK to a standard location for tools that expect it
  home.file."Android/Sdk".source = "${androidSdk}/share/android-sdk";

  # Sway configuration
  my.desktop.sway = {
    enable = true;
    fontSize = 10;
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
    nix-update = "nix flake update --commit-lock-file";
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

  programs.fish.shellInit = "";

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
    extraConfig = ''
      Include ~/dotfiles/secrets/ssh-config
    '';
    matchBlocks = {
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
    };
  };

  # Local-only SSH config is included via programs.ssh.extraConfig.

  # Swaylock configuration
  home.file.".config/swaylock/config".source = ../config/swaylock/config;

  # Wlogout configuration
  home.file.".config/wlogout".source = ../config/wlogout;

  # Thunar volume manager configuration
  home.file.".config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml".source = ../config/xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml;

  # Fcitx5 configuration (manually managed part, if needed, though NixOS module handles most)
  # Linking profile to ensure correct input method order (keyboard-us first, then skk)
  home.file.".config/fcitx5/profile".source = ../config/fcitx5/profile;
  home.file.".config/fcitx5/conf/skk.conf".source = ../config/fcitx5/conf/skk.conf;

  # libskk rules for custom keybindings
  home.file.".config/libskk".source = ../config/libskk;

}
