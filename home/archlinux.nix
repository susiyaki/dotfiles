{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/archlinux/sway
    ../modules/archlinux/waybar
  ];

  # Linux-specific packages
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    grim
    slurp
    wf-recorder  # Screen recording
    wev          # Wayland event viewer

    # Display
    brightnessctl
    nwg-displays

    # Notification
    libnotify

    # Bluetooth
    blueman

    # Audio
    pavucontrol

    # Launcher
    wofi

    # File manager
    thunar
    tumbler  # Thumbnail generator for Thunar
    gvfs     # Virtual filesystem (for Thunar)

    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    font-awesome

    # Applications
    discord
    spotify
    celluloid  # Video player

    # Development
    android-tools
    dbeaver-bin

    # Arch Linux specific
    reflector  # Pacman mirror list updater

    # GTK theme
    adwaita-icon-theme
  ];

  # Linux-specific environment variables
  home.sessionVariables = {
    # Android SDK (Linux)
    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
  };

  # Linux-specific fish aliases
  programs.fish.shellAliases = {
    # Arch Linux mirror update (reflector)
    reflectorjp = "sudo reflector --country 'Japan' --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist";
  };

  # Linux-specific shell config
  programs.fish.shellInit = ''
    # mise (Linux)
    if test -f "$HOME/.local/bin/mise"
      $HOME/.local/bin/mise activate fish | source
    end
  '';

  # Alacritty - use Linux-specific config
  home.file.".config/alacritty" = {
    source = ../config/alacritty;
    recursive = true;
  };

  # Set Linux-specific alacritty config as default
  home.file.".config/alacritty/alacritty.toml".text = ''
    import = ["alacritty.linux.yml"]
  '';
}
