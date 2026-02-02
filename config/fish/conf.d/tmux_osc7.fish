# OSC 7 escape sequence to update tmux pane_current_path
# This allows tmux to track the current working directory of each pane

function __update_tmux_pwd --on-variable PWD
    if set -q TMUX
        # Send OSC 7 sequence to tmux to update pane_current_path
        printf '\033]7;file://%s%s\033\\' (hostname) (pwd | string replace --all / %2F)
    end
end

# Initial update when shell starts
if set -q TMUX
    __update_tmux_pwd
end
