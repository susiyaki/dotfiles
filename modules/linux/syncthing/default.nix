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
            id = "GBP6QY7-YK5ILLN-A2ODNQT-TNBQSCJ-E5GCCLP-PLGNQYV-WUEOHNF-PIJEZQ4";
            addresses = [ "tcp://100.94.98.31:22000" ];
          };
        };
        folders = {
          "Syncthing" = {
            path = "${config.home.homeDirectory}/Syncthing";
            devices = [ "smartphone" ];
          };
        };
      };
    };
  };
}
