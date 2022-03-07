#!/bin/sh

CHEZMOI_ROOT=$(chezmoi data | jq ".chezmoi.sourceDir" | sed -e 's/"//g')
MACHINE_NAME=$(chezmoi data | jq ".machine_name" | sed -e 's/"//g')
TARGET=$CHEZMOI_ROOT/data/pacman-${MACHINE_NAME}.txt

function main() {
  echo "Start backup of pacman libraries."
  echo ""
  echo " - Machine name: $MACHINE_NAME"
  echo " - Backup to: $TARGET"
  pacman -Qqe | grep -Fvx "$(pacman -Qqm)" > $TARGET
  echo ""
  echo "Backup pacman libraries is completed."
}

main
