#!/bin/bash

set -euo pipefail

# for now, this script is only configured to run on mac
if ! [[ "$(uname)" == "Darwin" ]]; then
    echo "$0 only works on mac"
    exit 1
fi

LATEST_SS="$(ls -t $HOME/Desktop | grep Screenshot | head -n 1)"
mv "$HOME/Desktop/$LATEST_SS" "$HOME/Desktop/ss.png"
echo "Transcribe the following image" | lm --imageFiles "$HOME/Desktop/ss.png"
