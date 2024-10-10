#!/bin/bash

# Share contents of current directory and subdirectories
# I use this to shuttle files locally from machine to machine
#
# On machine you want to share from:
#
# ```bash
# ./share.sh
# ```
#
# On machine you want to pull file(s) to:
#
# ```bash
# curl -o shell-scripts.tar.gz localhost:8080/shell-scripts.tar.gz
# gunzip shell-scripts.tar.gz
# tar -xvf shell-scripts.tar
# rm shell-scripts.tar
# ```

set -euo pipefail

# Remember the current directory
PWD=$(pwd)

trap ctrl_c INT

function ctrl_c {
  kill -9 $PID
  rm -rf /tmp/"$rand"
  cd "$PWD"
}

function random_string {
  # https://linuxhint.com/generate-random-string-bash/
  echo $RANDOM | md5sum | head -c 20
}

function usage {
  echo "Usage: $0 [-p PORT] [-b BIND] TARGET"
  exit 1
}

# Set args
PORT=8080
BIND="0.0.0.0"
while getopts "p:b:h" opt; do
  case "$opt" in
    b)
      BIND="$OPTARG"
      ;;
    p)
      PORT="$OPTARG"
      ;;
    h)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

# Figure out what we want to tar
shift "$(( OPTIND - 1 ))"
FILEPATH="${1:-"."}"

echo "Serving files from $FILEPATH" >&2
if [[ -z $FILEPATH ]]; then
  FILEPATH="."
fi
FILEPATH=$(realpath "$FILEPATH")

rand=$(random_string)
if [[ -d $FILEPATH ]]; then
    # https://stackoverflow.com/questions/23162299/how-to-get-the-last-part-of-dirname-in-bash
    BASENAME="$(basename "$FILEPATH")"
    DIRNAME="$(dirname "$FILEPATH")"
    cd "$DIRNAME" || exit
    mkdir /tmp/"$rand"
    #tar --exclude=".*" -zcvf /tmp/"$rand"/"$BASENAME".tar.gz "$BASENAME"
    tar -zcvf /tmp/"$rand"/"$BASENAME".tar.gz "$BASENAME"
elif [[ -f $FILEPATH ]]; then
    BASENAME="$(basename "$FILEPATH")"
    mkdir /tmp/"$rand"
    cp "$FILEPATH" /tmp/"$rand"/"$BASENAME"
else
    echo "$FILEPATH is not valid"
    exit 1
fi

cd /tmp/"$rand" || exit
python -m http.server --bind "$BIND" "$PORT" &
PID=$!
wait
