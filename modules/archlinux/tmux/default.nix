{ config, pkgs, ... }:

{
  # Tmux systemd service
  systemd.user.services.tmux = {
    Unit = {
      Description = "tmux default session (detached)";
      Documentation = "man:tmux(1)";
    };

    Service = {
      Type = "forking";
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
      KillMode = "control-group";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
