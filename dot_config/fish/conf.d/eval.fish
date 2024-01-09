eval (ssh-agent -c) >/dev/null

if [ (uname -s) = "Darwin" ]
  eval (/opt/homebrew/bin/brew shellenv) >/dev/null

  # asdf
  if type -q asdf
    source /opt/homebrew/opt/asdf/libexec/asdf.fish
  end
else
  keychain -q $HOME/.ssh/github/id_rsa
  source $HOME/.keychain/(hostname)-fish

  # asdf
  if test -f /opt/asdf-vm/asdf.fish
    source /opt/asdf-vm/asdf.fish
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

