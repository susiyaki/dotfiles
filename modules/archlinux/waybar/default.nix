{ config, pkgs, ... }:

{
  # Waybar status bar configuration
  home.file.".config/waybar" = {
    source = ../../../config/waybar;
    recursive = true;
  };

  # Waybar package
  home.packages = with pkgs; [
    waybar
  ];
}
