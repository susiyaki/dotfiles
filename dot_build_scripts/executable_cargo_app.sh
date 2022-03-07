#!/bin/bash

TARGET=(
  bat
  exa
  ripgrep
  ytop
  cargo-atcoder
)

check_cargo_installed() {
  if !(type "cargo" > /dev/null); then
    echo "cargo is installing..."
    curl https://sh.rustup.rs -sSf | sh
  fi
}

check_cargo_installed

has() { type "$1" &>/dev/null; }

echo_skip() { echo "[✔] $1 was already installed"; }
echo_install() { echo "[✔] $1 will install..."; }

install() {
  if has $1; then
    echo_skip $1
  else
    echo_install $1

    case $1 in
      "bat")
        cargo install bat
        ;;
      "exa")
        cargo install exa
        ;;
      "ripgrep")
        cargo install ripgrep
        ;;
      "ytop")
        cargo install ytop
        ;;
      "cargo-atcoder")
        cargo install cargo-atcoder
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
        echo $t
        install $t
      done
      ;;
    "-l" | "--list")
      show_list
      ;;
    "bat")
      install "bat"
      ;;
    "exa")
      install "exa"
      ;;
    "ripgrep")
      install "ripgrep"
      ;;
    "ytop")
      install "ytop"
      ;;
    *)
      echo "no match target. run [-l|--l]"
      ;;
  esac
done
