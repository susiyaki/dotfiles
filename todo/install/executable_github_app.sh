#!/bin/bash

TARGET=(
  tpm
  packer.nvim
)

check_git_installed() {
  if !(type "git" > /dev/null); then
    echo "git isn't installed..." 1>&2
    exit 1
  fi
}

check_git_installed

place() { ls -d "$1" &>/dev/null; }

echo_skip() { echo "[✔] $1 was already installed"; }
echo_install() { echo "[✔] $1 will install..."; }

install() {
  if place $2; then
    echo_skip $1
  else
    echo_install $1

    case $1 in
      "tpm")
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        ;;
      "packer.nvim")
        git clone https://github.com/wbthomason/packer.nvim $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
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
fi

for i in ${@}; do
  case $i in
    "--all")
      for t in ${TARGET[@]}; do
        echo $t
        install $t
      done
      ;;
    "-l" | "--list")
      show_list
      ;;
    "tpm")
      install "tpm"
      ;;
    "packer.nvim")
      install "packer.nvim"
      ;;
    *)
      echo "no match target. run [-l|--l]"
      ;;
  esac
done
