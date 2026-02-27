{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.syncthing;
in
{
  options.my.services.syncthing = {
    enable = lib.mkEnableOption "Syncthing service";
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = true;
      settings = {
        devices = {
          "smartphone" = {
            id = "HDMXDYP-VTTKVSJ-YTK5ONQ-Q36KJ5S-7RQRHY2-2HHSDML-7MV54BV-YZWJNQ4";
            addresses = [ "tcp://100.94.98.31:22000" ];
          };
        };
        folders = {
          "Syncthing" = {
            path = "${config.home.homeDirectory}/Syncthing";
            devices = [ "smartphone" ];
          };
          "High Climb" = {
            path = "${config.home.homeDirectory}/Workspaces/susiyaki/high_climb/Syncthing";
            devices = [ "smartphone" ];
          };
        };
      };
    };
  };
}
