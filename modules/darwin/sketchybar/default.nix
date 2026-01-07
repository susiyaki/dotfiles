{ config, pkgs, ... }:

{
  # SketchyBar status bar configuration
  home.file.".config/sketchybar" = {
    source = ../../../config/sketchybar;
    recursive = true;
  };

  # Launchd service to start SketchyBar at login
  launchd.agents.sketchybar = {
    enable = true;
    config = {
      ProgramArguments = [ "/opt/homebrew/bin/sketchybar" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/sketchybar.out.log";
      StandardErrorPath = "/tmp/sketchybar.err.log";
    };
  };
}
