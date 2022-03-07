#!/bin/bash

mkdir -p ~/Pictures

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# open screenshot tool
scrot -s -o ~/Pictures/$TIMESTAMP.png

# remove outer pixel rows because they sometimes include the capture border
mogrify -crop +1+1 -crop -1-1 +repage ~/Pictures/$TIMESTAMP.png

# copy to clipboard
xclip -sel clip -t image/png -i ~/Pictures/$TIMESTAMP.png

# Alternatively: upload to imgbb, keep for 1h
#RES=`curl --location --request POST -F "image=@$HOME/Pictures/screenshot.png" "https://api.imgbb.com/1/upload?expiration=3600&key=YOUR_API_KEY_HERE"`
#echo $RES | jq -r '.data.url' | xclip -sel clip -i
