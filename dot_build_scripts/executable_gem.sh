#!jbin/bash

TARGET=(
  neovim
)

check_ruby() {
  if !(type "rbenv" > /dev/null 2>&1); then
    echo "
    You have to insall rbenv
    See in $DOTPATH/bin/initialize
    " 1>&2
    exit 1
  fi
}

check_ruby

has() { type "$1" &>/dev/null; }

echo_skip() { echo "[✔] $1 was already installed"; }
echo_install() { echo "[✔] $1 will install..."; }

install() {
  if has $1; then
    echo_skip $1
  else
    echo_install $1

    case $1 in
      "neovim")
        gem install neovim
        ;;
      *)
        echo "unexpand error occuerd!!"
        ;;
    esac
  fi
}

show_list() {
  echo "
  Choose from below commands ▼
  "
  echo "    ● --all: install all targets."
  echo "    ● [-l|--list]"
  for t in ${TARGET[@]}; do
    echo "    ● $t"
  done
}

if ! [ ${@} ]; then
  show_list
  exit 1
fi

for i in ${@}; do
  case $i in
    "--all")
      for t in ${TARGET[@]}; do
        install $t
      done
      ;;
    "-l" | "--list")
      show_list
      ;;
    "neovim")
      install "neovim"
      ;;
    *)
      echo "[error] no match target"
      ;;
  esac
done
