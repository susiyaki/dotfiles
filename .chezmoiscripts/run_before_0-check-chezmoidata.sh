#!/bin/sh

MACHINE_NAME=$(chezmoi data | jq ".machine_name" | sed -e 's/"//g')
CHEZMOI_ROOT=$(chezmoi data | jq ".chezmoi.sourceDir" | sed -e 's/"//g')
CHEZMOI_DATA=(
  "machine_name"
)

ERROR=0

function get_chezmoidata() {
  echo $(chezmoi data | jq ".$1")
}

function main() {
  echo "Checking .chezmoidata.toml..."
  echo ""

  if [ ! -f $CHEZMOI_ROOT/.chezmoidata.toml ]; then
    echo ".chezmoidata.toml is not exists."
    exit 1
  fi
  for d in ${CHEZMOI_DATA[@]}
  do
    if [ -z $(get_chezmoidata $d) ]; then
      echo "[x] $d"
      ERROR=1
    else
      echo "[○] $d"
    fi
  done

  echo ""

  if [ $ERROR == 1 ]; then
    echo "Error occured duaring checking .chezmoidata.toml."
    exit 1
  else
    echo "Succeeded to check .chezmoidata.toml."

  fi
}

main
