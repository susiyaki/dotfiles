#!/bin/sh

CHEZMOI_ROOT=$(chezmoi data | jq ".chezmoi.sourceDir")

function make_symbolic_link() {
  source=$1
  target=$2

  if [ -e $target ]; then
    # Check exists file is symbolic link.
    if [ -L $target ]; then
      echo "[-] $target"
    else
      read -p "  > Override $target? " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[-] $target"
      else
        sudo ln -s $source $target
        echo "[✔] $target"
      fi
    fi
  else
    sudo ln -s $source $target
    echo "[✔] $target"
  fi
}

function main() {
  for f in $(find $PWD -type f); do
    if [ $f != "$PWD/run_onchange_make-symbolic-link.sh" ]; then
      source=$f
      target="${source/$PWD/}"
      make_symbolic_link $source $target
    fi
  done
}

main
