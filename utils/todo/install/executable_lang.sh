#!/bin/bash

LANG_PATH=$HOME/dotfiles/install/lang
LANGS=$(ls $LANG_PATH | sed -e "s/.sh//g")

command=$1

show_list() {
  echo "
  Choose from below commands ▼
  "
  echo "    ● [-l|--list]"
  echo "    ● [--all]"
  for l in ${LANGS[@]}; do
    echo "    ● $l"
  done
}

if ! [ $command ]; then
  show_list
  exit 1
fi

if [[ " ${LANGS[@]} " =~ " $command " ]]; then
  show_list
  exit 1
fi

echo_skip() { echo "[✔] $1 was already installed"; }
echo_install() { echo "[✔] $1 will install..."; }

install() {
  if command -v $1 1>/dev/null 2>&1; then
    echo_skip $1
  else
    echo_install $1
    sh $LANG_PATH/$1.sh
  fi
}
case $command in
  "-l" | "--list")
    show_list
    ;;
  "--all")
    for l in ${LANGS[@]}; do
      install $l
    done
    ;;
  *)
    install $command
    ;;
esac
