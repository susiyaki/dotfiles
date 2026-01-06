{ config, pkgs, ... }:

{
  # Xremap package
  home.packages = with pkgs; [
    xremap
  ];

  # Xremap configuration
  home.file.".config/xremap/config.yml".source = ../../../config/xremap/config.yml;

  # Xremap systemd service
  systemd.user.services.xremap = {
    Unit = {
      Description = "xremap - keyboard remapper";
      BindsTo = "sway-session.target";
      After = "sway-session.target";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.xremap}/bin/xremap %h/.config/xremap/config.yml";
      ExecStop = "${pkgs.procps}/bin/pkill xremap";
      Restart = "always";
      RestartSec = 1;
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
