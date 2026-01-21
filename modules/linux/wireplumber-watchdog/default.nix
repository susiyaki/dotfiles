{ config, pkgs, ... }:

{
  # wireplumber-watchdog script
  home.file.".local/bin/wireplumber-watchdog.sh" = {
    source = ../../../scripts/linux/wireplumber-watchdog.sh;
    executable = true;
  };

  # WirePlumber microphone priority configuration
  home.file.".config/wireplumber/wireplumber.conf.d/51-microphone-priority.conf".source =
    ../../../config/wireplumber/wireplumber.conf.d/51-microphone-priority.conf;

  # WirePlumber CPU Watchdog systemd service
  systemd.user.services.wireplumber-watchdog = {
    Unit = {
      Description = "WirePlumber CPU Watchdog Service";
      Documentation = "https://gitlab.freedesktop.org/pipewire/wireplumber";
      After = [ "wireplumber.service" "sway-session.target" ];
      PartOf = "pipewire-session-manager.service";
      BindsTo = "sway-session.target";
    };

    Service = {
      Type = "simple";
      ExecStart = "%h/.local/bin/wireplumber-watchdog.sh";
      Restart = "on-failure";
      RestartSec = 10;
      Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus";
      MemoryMax = "50M";
      CPUQuota = "10%";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
