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
    gammastep  # Redshift fork with better Wayland support
  ];

  # Systemd services for Sway session
  systemd.user.services = {
    # Kanshi - Dynamic display configuration
    kanshi = {
      Unit = {
        Description = "Dynamic output configuration for Wayland compositors";
        Documentation = "https://sr.ht/~emersion/kanshi";
        BindsTo = "sway-session.target";
        After = "sway-session.target";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanshi}/bin/kanshi";
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    # Gammastep - Display color temperature control (Redshift fork for Wayland)
    gammastep = {
      Unit = {
        Description = "Control display color temperature with gammastep";
        Documentation = "https://gitlab.com/chinstrap/gammastep";
        BindsTo = "sway-session.target";
        After = "sway-session.target";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.gammastep}/bin/gammastep";
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
