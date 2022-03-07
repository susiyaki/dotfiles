#!/bin/bash

# NOTE 順番アリ
TARGET=(
  metalua
  penlight
  formatter
)

check_luaenv_installed() {
  if !(type "luaenv" > /dev/null 2>&1); then
    echo "
    You have to insall luaenv
    See in $DOTPATH/bin/initialize
    " 1>&2
    exit 1
  fi
}

check_lualocks_installed() {
  if !(type "luarocks" > /dev/null 2>&1); then
    echo "
    You have to insall luarocks
    After install luaenv and set global lua version, run following
      luaenv luarocks -l
      luaenv luarocks [version]
    " 1>&2
    exit 1
  fi
}

check_luaenv_installed
check_lualocks_installed

has() { type "$1" &>/dev/null; }

echo_skip() { echo "[✔] $1 was already installed"; }
echo_install() { echo "[✔] $1 will install..."; }

install() {
  if has $1; then
    echo_skip $1
  else
    echo_install $1

    case $1 in
      "metalua")
        luarocks install metalua
        ;;
      "penlight")
        luarocks install penlight
        ;;
      "formatter")
        luarocks install formatter
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
    "metalua")
      install "metalua"
      ;;
    "penlight")
      install "penlight"
      ;;
    "formatter")
      install "formatter"
      ;;
    *)
      echo "[error] no match target"
      ;;
  esac
done
