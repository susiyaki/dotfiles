source $HOME/.keychain/(hostname)-fish
eval (keychain --eval --agents ssh --quiet)

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
