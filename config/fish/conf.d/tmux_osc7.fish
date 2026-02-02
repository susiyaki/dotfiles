# OSC 7 escape sequence to update tmux pane_current_path
# This allows tmux to track the current working directory of each pane
# Darwin only - not needed on Linux

# Skip if not on Darwin
if test (uname) != Darwin
    exit 0
end

function __update_tmux_pwd --on-variable PWD
    if set -q TMUX
        # tmuxのペイン環境変数に現在のパスを設定
        # これにより、new-windowやsplit-windowが現在のディレクトリを使用できる
        # tmux IDの特殊文字($, @, %)を削除してFish変数名として有効にする
        set -l tmux_id (tmux display-message -p '#{session_id}_#{window_id}_#{pane_id}' | string replace -ra '[\$@%]' '')
        tmux set-environment TMUXPWD_"$tmux_id" "$PWD" 2>/dev/null

        # OSC 7をttyに直接送信（標準出力を汚染しない）
        # これによりターミナルエミュレータも現在のディレクトリを追跡できる
        if test -t 1
            printf '\033]7;file://%s%s\033\\' (hostname) (string escape --style=url $PWD) >/dev/tty
        end
    end
end

# Initial update when shell starts
if set -q TMUX
    __update_tmux_pwd
end
