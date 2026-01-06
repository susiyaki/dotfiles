{ config, pkgs, ... }:

{
  # Wofi configuration
  home.file.".config/wofi" = {
    source = ../../../config/wofi;
    recursive = true;
  };
}
