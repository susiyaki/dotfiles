#!/bin/bash

PRIMARY=eDP1
MODE_FILE=$HOME/.screenlayout/mode.txt
DISPLAY_COUNT=4
mode=$(cat "$MODE_FILE")
next_mode=
next_mode_text=

function connected_wavlink() {
	if [[ $(xrandr | grep " connected " | awk '{print $1}' | wc -l) == "$DISPLAY_COUNT" ]]; then
		return 0
	else
		return 1
	fi
}

function change_mode() {
	echo $next_mode >"$MODE_FILE"
	notify-send "Change display mode" "$next_mode_text"
}

function set_single_monitor() {
	source ~/.screenlayout/single.sh
	next_mode=1
	next_mode_text="Single mode"
}

function set_multiple_monitors() {
	source ~/.screenlayout/multiple.sh
	next_mode=2
	next_mode_text="Multiple mode - 2"
}

if connected_wavlink; then
	# mode
	#  1: single monitor
	#  2: multiple monitors
	case $mode in
	1)
		set_multiple_monitors
		;;
	2)
		set_single_monitor
		;;
	*)
		set_single_monitor
		;;
	esac
else
	set_single_monitor
fi

function check_file() {
	if [ ! -f "$MODE_FILE" ]; then
		touch "$MODE_FILE"
		echo set_single_monitor
	fi
}

check_file
change_mode
