#!/bin/bash

TARGET=(
  shfmt
  sqlfmt
)

check_go_installed() {
  if (type "$go" >/dev/null 2>&1); then
    echo "
    You have to insall go
    If you already install go, you may forget set default version
    " 1>&2
    exit 1
  fi
}

check_go_installed

has() { type "$1" &>/dev/null; }

echo_skip() { echo "[✔] $1 was already installed"; }
echo_install() { echo "[✔] $1 will install..."; }

install() {
  if has $1; then
    echo_skip $1
  else
    echo_install $1

    case $1 in
      "shfmt")
        GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt
        ;;
      "sqlfmt")
        go get github.com/jackc/sqlfmt/...
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
    "shfmt")
      install "shfmt"
      ;;
    "sqlfmt")
      install "sqlfmt"
      ;;
    *)
      echo "[error] no match target"
      ;;
  esac
done
