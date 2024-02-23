alias relogin="fish"

# git
abbr g git

# docker
abbr d docker
abbr dc docker-compose

# fzf
abbr f fzf

# directory指定省略
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -p"

# sudo の後のコマンドでエイリアスを有効にする
alias sudo="sudo "

# lazygit
# docui
abbr gl lazygit
abbr dl lazydocker

# nvim
if type -q nvim
  if type -q tmux
    alias vim="tmux new-window nvim"
    alias vi="tmux new-window nvim"
  else
    alias vim="nvim"
    alias vi="nvim"
  end
end

# rust apps
if type -q exa
  alias ls="exa"
  alias la="exa -a"
  alias ll="exa -l"
else
  alias la="ls -a"
  alias ll="ls -l"
end

if type -q bat
  alias cat="bat"
end

if type -q ytop
  alias top="ytop"
end

alias reflectorjp="sudo reflector --country 'Japan' --age 24 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
