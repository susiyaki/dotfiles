{ config, pkgs, ... }:

{
  # Speak to AI - Offline Speech-to-Text systemd user service
  # NOTE: This package is not available in nixpkgs as of 2026-01-20
  # See README.md for installation instructions

  # NixOS: Uncomment once speak-to-ai is available on your system
  # systemd.user.services.speak-to-ai = {
  #   Unit = {
  #     Description = "Speak to AI - Offline Speech-to-Text Daemon";
  #     Documentation = "https://github.com/speak-to-ai/speak-to-ai";
  #     After = [ "pipewire.service" "pipewire-pulse.service" ];
  #     Requires = [ "pipewire.service" ];
  #   };
  #
  #   Service = {
  #     Type = "simple";
  #     # If packaged: ExecStart = "${pkgs.speak-to-ai}/bin/speak-to-ai -config %h/.config/speak-to-ai/config.yaml";
  #     # If built manually: ExecStart = "%h/.local/bin/speak-to-ai -config %h/.config/speak-to-ai/config.yaml";
  #     ExecStart = "%h/.local/bin/speak-to-ai -config %h/.config/speak-to-ai/config.yaml";
  #     Restart = "on-failure";
  #     RestartSec = 5;
  #
  #     Environment = [
  #       "XDG_RUNTIME_DIR=/run/user/%U"
  #       "PULSE_SERVER=unix:/run/user/%U/pulse/native"
  #       "PIPEWIRE_RUNTIME_DIR=/run/user/%U"
  #     ];
  #
  #     StandardOutput = "journal";
  #     StandardError = "journal";
  #   };
  #
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };
}
