{ config, pkgs, ... }:

{
  # Aerospace window manager configuration
  home.file.".config/aerospace" = {
    source = ../../../config/aerospace;
    recursive = true;
  };
}
