#!/bin/bash

directory=$(mktemp -d)
cat /dev/stdin > "$directory/index.html"
python -m http.server --bind localhost --dir "$directory" "$@"
