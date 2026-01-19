{ config, pkgs, ... }:

{
  # Sway window manager configuration
  home.file.".config/sway" = {
    source = ../../../config/sway;
    recursive = true;
  };

  # Additional sway-related configs
  home.file.".config/swaync".source = ../../../config/swaync;
  home.file.".config/kanshi".source = ../../../config/kanshi;
  home.file.".config/speak-to-ai/config.yaml".source = ../../../config/speak-to-ai/config.yaml;

  # Sway-specific packages
  home.packages = with pkgs; [
    swayidle
    swaybg
    wl-clipboard
    grim
    slurp
    kanshi
    gammastep  # Redshift fork with better Wayland support
    wtype  # Wayland keyboard input emulator (for speak-to-ai)
    libnotify  # Desktop notifications (for speak-to-ai)
  ];

  # Systemd target for Sway session
  systemd.user.targets.sway-session = {
    Unit = {
      Description = "Sway compositor session";
      Documentation = "man:systemd.special";
      BindsTo = "graphical-session.target";
      Wants = "graphical-session-pre.target";
      After = "graphical-session-pre.target";
    };
  };

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

    # Speak to AI - Offline Speech-to-Text Daemon
    # NOTE: Arch Linuxでは /usr/bin/speak-to-ai を使用
    #       NixOSでは modules/linux/speak-to-ai/default.nix を参照
    speak-to-ai = {
      Unit = {
        Description = "Speak to AI - Offline Speech-to-Text Daemon";
        Documentation = "https://github.com/speak-to-ai/speak-to-ai";
        BindsTo = "sway-session.target";
        After = [ "sway-session.target" "pipewire.service" "pipewire-pulse.service" ];
        Requires = [ "pipewire.service" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "/usr/bin/speak-to-ai -config %h/.config/speak-to-ai/config.yaml";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          "PULSE_SERVER=unix:/run/user/%U/pulse/native"
          "PIPEWIRE_RUNTIME_DIR=/run/user/%U"
        ];
      };

      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
