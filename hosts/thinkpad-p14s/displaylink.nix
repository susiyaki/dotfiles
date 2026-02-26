{ config, pkgs, ... }:

let
  displaylink = pkgs.displaylink.override {
    evdi = config.boot.kernelPackages.evdi;
  };
in
{
  # DisplayLink support for external monitors (requires manual download due to EULA).
  # Download: https://www.synaptics.com/products/displaylink-usb-graphics-software-ubuntu-62
  services.xserver.videoDrivers = [
    "modesetting"
  ];

  # DisplayLink (manual enable since this nixpkgs doesn't accept "displaylink" in videoDrivers)
  environment.etc."X11/xorg.conf.d/40-displaylink.conf".text = ''
    Section "OutputClass"
      Identifier  "DisplayLink"
      MatchDriver "evdi"
      Driver      "modesetting"
      Option      "TearFree" "true"
      Option      "AccelMethod" "none"
    EndSection
  '';

  services.udev.packages = [ displaylink ];

  systemd.services.dlm = {
    description = "DisplayLink Manager Service";
    after = [ "display-manager.service" ];
    conflicts = [ "getty@tty7.service" ];

    serviceConfig = {
      ExecStart = "${displaylink}/bin/DisplayLinkManager";
      Restart = "always";
      RestartSec = 5;
      LogsDirectory = "displaylink";
    };
  };
}
