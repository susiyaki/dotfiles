#!/bin/sh

CHEZMOI_ROOT=$(chezmoi data | jq ".chezmoi.sourceDir" | sed -e 's/"//g')
MACHINE_NAME=$(chezmoi data | jq ".machine_name" | sed -e 's/"//g')
SOURCE=$CHEZMOI_ROOT/data/pacman-${MACHINE_NAME}.txt

main() {
  echo "Import pacman libraries from $SOURCE."
  echo ""
  echo " - Machine name: $MACHINE_NAME"
  echo " - Import from: $SOURCE"
  xargs pacman -S --needed < "$SOURCE"
  echo ""
  echo "Restore pacman libraries is completed."
}

main
