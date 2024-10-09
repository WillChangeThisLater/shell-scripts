#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <website>"
  exit 1
fi

site="$1"
# See: https://gist.github.com/stvhwrd/985dedbe1d3329e68d70
wget --limit-rate=200k --no-clobber --convert-links --random-wait -r -p -E -e robots=off -U mozilla "$site"
