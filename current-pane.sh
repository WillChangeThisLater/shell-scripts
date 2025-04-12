#!/bin/bash
#
#set -euo pipefail
#
#screenshot_pane() {
#    tmux capture-pane
#    tmux show-buffer
#}
#
#tmux capture-pane -p

set -euo pipefail

# Function to take a screenshot of the tmux pane
screenshot_pane() {
    if [[ $# -eq 1 ]]; then
        # If a number of lines is provided, use it
        tmux capture-pane -p -S "-$1"
    else
        # Capture the entire pane without specifying the number of lines
        tmux capture-pane -p
    fi
}

# Initialize num_lines variable
num_lines=""

# Parse the command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --num-lines)
            num_lines="$2"
            shift 2 # Shift past the --num-lines and its value
            ;;
        *)
            echo "Usage: $0 [--num-lines <num_lines>]"
            exit 1
            ;;
    esac
done

# Call screenshot_pane with optional num_lines
if [[ -n "$num_lines" ]]; then
    screenshot_pane "$num_lines"
else
    screenshot_pane
fi
