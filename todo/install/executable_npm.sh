#!/bin/bash

TARGET=(
  stylelint
  prettier
  neovim
  yarn
)

check_node() {
  if !(type "nodenv" > /dev/null 2>&1); then
    echo "
    You have to insall nodenv
    See in $DOTPATH/bin/initialize
    " 1>&2
    exit 1
  fi

  node_version=$(node -v | sed -e "s/v//")
  nodenv_global_version=$(nodenv version | awk '{print $1}')

  if [ $node_version != $nodenv_global_version ]; then
    echo "
    Not equal node -v and nodenv version
    Neet check path
    " 1>&2
    exit 1
  fi

}

check_node

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
        npm i -g neovim
        ;;
      "stylelint")
        npm i -g stylelint
        ;;
      "prettier")
        npm i -g prettier
        ;;
      "prettier")
        npm i -g yarn
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
    "stylelint")
      install "stylelint"
      ;;
    "prettier")
      install "prettier"
      ;;
    "yarn")
      install "yarn"
      ;;
    *)
      echo "[error] no match target"
      ;;
  esac
done
