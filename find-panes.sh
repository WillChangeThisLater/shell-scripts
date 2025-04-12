#!/bin/bash

set -euo pipefail

#```bash
#> tmux list-panes
#0: [94x24] [history 1182/50000, 2418113 bytes] %10
#1: [93x24] [history 895/50000, 1404064 bytes] %6
#2: [94x23] [history 1/50000, 124457 bytes] %5
#3: [188x48] [history 1164/50000, 4157881 bytes] %8 (active)
#```
get_panes() {
	tmux list-panes | grep -vi "active" | awk '{print $1}' | sed 's|:||g'
}

screenshot_pane() {
	echo "capturing pane $1" >&2
	tmux capture-pane -t "$1"
cat <<EOF
\`\`\`pane-$1
$(tmux show-buffer)
\`\`\`
EOF
}

screenshot_panes() {
    for pane in $(get_panes); do
    	echo
    	echo "****************"
    	screenshot_pane "$pane" 2>/dev/null
    	echo "****************"
    	echo
    done
}

get_relevant_panes() {
cat <<EOF | llm --schema-multi "panes int" | jq -r '.items[].panes'
Which of the following pane(s) is relevant to the prompt?
Return only the pane number

PROMPT:
$1

PANES:
$(screenshot_panes)
EOF
}

main() {
    for pane in $(get_relevant_panes "$1"); do
        echo
        echo "****************"
        screenshot_pane "$pane" 2>/dev/null
        echo "****************"
        echo
    done
}

main "$@"
