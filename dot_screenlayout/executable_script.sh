#!/bin/bash

PRIMARY=eDP1
MODE_FILE=$HOME/.screenlayout/mode.txt
mode=$(cat $MODE_FILE)
next_mode=
next_mode_text=

# Connected 2 external monitors via wavlink
function connected_wavlink () {
  if [[ $(xrandr | grep " connected " | awk '{print $1}' | wc -l) == 3 ]]; then
    return 0
  else
    return 1
  fi
}

function change_mode () {
  echo $next_mode > $MODE_FILE
  notify-send "Change display mode" $next_mode_text
}

function set_single_monitor () {
  source ~/.screenlayout/single.sh
  next_mode=1
  next_mode_text="Single mode"
}

function set_multiple_monitors () {
  source ~/.screenlayout/multiple.sh
  next_mode=2
  next_mode_text="Multiple mode - 3"
}

function set_multiple2_monitors () {
  source ~/.screenlayout/multiple2.sh
  next_mode=3
  next_mode_text="Multiple mode - 2"
}

if connected_wavlink; then
  # mode
  #  1: single monitor
  #  2: multiple monitors
  #  3: multiple2 monitors
  case $mode in
    1)
      set_multiple_monitors
      ;;
    2)
      set_multiple2_monitors
      ;;
    3)
      set_single_monitor
      ;;
    *)
      set_single_monitor
      ;;
  esac
else
  set_single_monitor
fi

change_mode
