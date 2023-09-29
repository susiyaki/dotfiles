eval (ssh-agent -c) >/dev/null
keychain -q $HOME/.ssh/github/id_rsa
source $HOME/.keychain/(hostname)-fish

# direnv
if type -q direnv
    eval (direnv hook fish | source)
end

# github cli
if type -q gh
    eval (gh completion -s fish | source)
end

# asdf
if test -f /opt/asdf-vm/asdf.fish
  source /opt/asdf-vm/asdf.fish
end
