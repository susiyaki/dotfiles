#!/bin/bash

git clone https://github.com/flutter/flutter.git $HOME/flutter

export PATH="$PATH:$HOME/flutter/bin"

flutter

dart pub global activate fvm

fvm install stable

fvm global stable

rm -rf $HOME/flutter
