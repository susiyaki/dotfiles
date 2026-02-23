# profiles/desktop.nix
{ pkgs, ... }:

{
  # Assume this profile is only imported on desktop environments
  home.packages = with pkgs; [
    # Browser
    firefox
    google-chrome

    # Communication
    slack
    discord

    # Terminal
    alacritty

    # Wayland Utilities
    clipman
    wf-recorder
    wev
    wl-mirror
    wlr-randr
    wlogout
    swaynotificationcenter
    wofi
    rofi
    wdisplays
    swappy

    # System Utilities
    blueman
    pavucontrol
    playerctl
    brightnessctl
    nwg-displays
    networkmanagerapplet
    pamixer
    btop
    nvtopPackages.amd
    psmisc

    # File Manager
    thunar
    tumbler
    gvfs
    thunar-volman
    thunar-archive-plugin
    xarchiver

    # Media
    # Temporarily disabled to avoid deno build via mpv/yt-dlp.
    # celluloid
    # mpv
    vlc
    imv

    # Misc GUI Apps
    gnome-calculator
    lxappearance

    # GTK Theme & Icons
    adwaita-icon-theme
    gnome-themes-extra
    gtk-engine-murrine
  ];

  # As per plan, but note that config is still managed via home.file
  # This can be refactored into a module later.
  programs.alacritty.enable = true;
}
