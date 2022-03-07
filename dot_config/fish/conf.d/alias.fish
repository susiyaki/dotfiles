alias relogin="fish"

# git
abbr g git

# docker
abbr d docker
abbr dc docker-compose

# fzf
abbr f fzf

# atcoder
alias ca="cargo atcoder"

# directory指定省略
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -p"

# sudo の後のコマンドでエイリアスを有効にする
alias sudo="sudo "

# rails
alias rails="bundle exec rails"
alias be="bundle exec"
alias cap="bundle exec cap"
alias binstall="bundle install -j4"

# flutter
abbr fl "fvm flutter"
abbr fld "fvm flutter pub global run devtools"

# android
alias sdkmanager="sdkmanager --sdk_root='$ANDROID_SDK_ROOT'"

# lazygit
# docui
abbr gl lazygit
abbr dl lazydocker

# yarn
abbr y yarn
abbr yw "yarn workspace"
abbr yws "yarn workspaces"

# utern
alias cwlogs="aws logs describe-log-groups --query "logGroups[].[logGroupName]" --output text"

if type -q nvim
  if type -q tmux
    alias vim="tmux new-window nvim"
    alias vi="tmux new-window nvim"
    alias vis="tmux new-window nvim -S Session.vim"
  else
    alias vim="nvim"
    alias vi="nvim"
    alias vis="nvim -S Session.vim"
  end
end

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
