{ config, pkgs, ... }:

{
  # Waybar status bar configuration
  home.file.".config/waybar" = {
    source = ../../../config/waybar;
    recursive = true;
  };

  # Make scripts executable
  home.activation.makeWaybarScriptsExecutable = config.lib.dag.entryAfter ["writeBoundary"] ''
    chmod +x ~/.config/waybar/scripts/* || true
  '';

  # Waybar package
  home.packages = with pkgs; [
    waybar
  ];
}
