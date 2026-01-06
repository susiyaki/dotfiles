{ config, pkgs, ... }:

{
  # Aerospace window manager configuration
  home.file.".config/aerospace" = {
    source = ../../../config/aerospace;
    recursive = true;
  };

  # Make scripts executable
  home.activation.makeAerospaceScriptsExecutable = config.lib.dag.entryAfter ["writeBoundary"] ''
    chmod +x ~/.config/aerospace/scripts/* || true
  '';
}
