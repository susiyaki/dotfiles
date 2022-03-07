#!/bin/sh

CHEZMOI_ROOT=$(chezmoi data | jq ".chezmoi.sourceDir" | sed -e 's/"//g')
MACHINE_NAME=$(chezmoi data | jq ".machine_name" | sed -e 's/"//g')
TARGET=$CHEZMOI_ROOT/data/pacman-${MACHINE_NAME}.txt

function main() {
  echo "export pacman libraries to $TARGET"
  pacman -Qqe | grep -Fvx "$(pacman -Qqm)" > $TARGET
}

main
