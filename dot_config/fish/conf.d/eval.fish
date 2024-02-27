if status --is-interactive
    keychain --quiet --agents ssh
end

begin
    set -l HOSTNAME (hostname)
    if test -f ~/.keychain/$HOSTNAME-fish
        source ~/.keychain/$HOSTNAME-fish
    end
end

# direnv
if type -q direnv
    eval (direnv hook fish | source)
end

# github cli
if type -q gh
    eval (gh completion -s fish | source)
end

# mise
if test -f "$HOME/.local/bin/mise"
  $HOME/.local/bin/mise activate fish | source
end
