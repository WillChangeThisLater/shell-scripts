#!/bin/bash

set -euo pipefail

tmux capture-pane -p -S - | ghead -n -2 | pbcopy
tmux split-window -h 'pbpaste && zsh'
