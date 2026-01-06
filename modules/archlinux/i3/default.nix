{ config, pkgs, ... }:

{
  # i3 window manager configuration (optional)
  # Uncomment if you use i3 instead of Sway

  # home.file.".config/i3" = {
  #   source = ../../../config/i3;
  #   recursive = true;
  # };

  # home.packages = with pkgs; [
  #   i3
  #   i3status-rust
  #   dmenu
  # ];
}
