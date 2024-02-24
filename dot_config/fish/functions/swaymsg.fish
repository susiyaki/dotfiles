if set -q TMUX
  # inside tmux, we don't know if Sway got restarted
  function swaymsg
    set -l pid (pgrep -x sway)
    set -l uid (id -u)
    set -l sock "$XDG_RUNTIME_DIR/sway-ipc.$uid.$pid.sock"
    set -g SWAYSOCK $sock
    command swaymsg $argv
  end
end
