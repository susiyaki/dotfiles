{ config, pkgs, ... }:

{
  # Sway window manager configuration
  home.file.".config/sway" = {
    source = ../../../config/sway;
    recursive = true;
  };

  # Make scripts executable
  home.activation.makeSwayScriptsExecutable = config.lib.dag.entryAfter ["writeBoundary"] ''
    chmod +x ~/.config/sway/scripts/* || true
  '';

  # Additional sway-related configs
  home.file.".config/swaync".source = ../../../config/swaync;
  home.file.".config/kanshi".source = ../../../config/kanshi;

  # Sway-specific packages
  home.packages = with pkgs; [
    swayidle
    swaybg
    wl-clipboard
    grim
    slurp
    kanshi
  ];
}
