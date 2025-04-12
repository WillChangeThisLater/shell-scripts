#!/bin/bash

set -euo pipefail

# this script is meant for finding panes in the current tmux window matching a description
#
# for instance, my prompt might look like this:
#
# ```prompt.sh
# cat <<EOF
# I have the following script:
#
# \`\`\`main.py
# $(cat -n main.py)
# \`\`\`
#
# I want this script to contain JSON output.
# However, when I try to get the JSON from the
# response it fails with the following error:
#
# \`\`\`bash
# # limit to last 20 lines of traceback
# > python main.py | tail -n 20
# $(python main.py | tail -n 20 2>&1)
# \`\`\`
#
# Here is what my request looks like in mitmproxy (I have find-panes.sh linked to  my PATH):
#
# $(find-panes "find the pane that shows a request body in mitmproxy")
# EOF
# ```
#
# this might compile down to the following...
#####################################################
# I have the following script:
# 
# ```main.py
#      1  import requests
#      2
#      3  response = requests.get("https://www.ifconfig.me")
#      4  response.json()
# ```
# 
# I want this script to contain JSON output.
# However, when I try to get the JSON from the
# response it fails with the following error:
# 
# ```bash
# # limit to last 20 lines of traceback
# > python main.py | tail -n 20
# Traceback (most recent call last):
#   File "/home/arch/.pyenv/versions/bash/lib/python3.12/site-packages/requests/models.py", line 974, in json
#     return complexjson.loads(self.text, **kwargs)
#            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#   File "/home/arch/.pyenv/versions/3.12.4/lib/python3.12/json/__init__.py", line 346, in loads
#     return _default_decoder.decode(s)
#            ^^^^^^^^^^^^^^^^^^^^^^^^^^
#   File "/home/arch/.pyenv/versions/3.12.4/lib/python3.12/json/decoder.py", line 340, in decode
#     raise JSONDecodeError("Extra data", s, end)
# json.decoder.JSONDecodeError: Extra data: line 1 column 7 (char 6)
# 
# During handling of the above exception, another exception occurred:
# 
# Traceback (most recent call last):
#   File "/tmp/main.py", line 4, in <module>
#     response.json()
#   File "/home/arch/.pyenv/versions/bash/lib/python3.12/site-packages/requests/models.py", line 978, in json
#     raise RequestsJSONDecodeError(e.msg, e.doc, e.pos)
# requests.exceptions.JSONDecodeError: Extra data: line 1 column 7 (char 6)
# ```
# 
# Here is what my request looks like in mitmproxy:
# 
# 
# ****************
# ```pane-2
# Flow Details
# 2025-04-12 14:56:37 GET https://www.ifconfig.me/
#                         ← 200 OK text/plain 14b 88ms
#             Request                         Response                        Detail
# Host:             www.ifconfig.me
# User-Agent:       python-requests/2.32.3
# Accept-Encoding:  gzip, deflate, br, zstd
# Accept:           */*
# Connection:       keep-alive
# No request content                                                                    [m:auto]
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# ⇩  [12/12]                                                                            [*:8888]
# Flow:    e Edit        D Duplicate   r Replay      x Export      d Delete      b Save body
# Proxy:   ? Help        q Back        E Events      O Options     i Intercept   f Filter
# ```
# ****************
#####################################################


get_panes() {
        #```bash
        #> tmux list-panes
        #0: [94x24] [history 1182/50000, 2418113 bytes] %10
        #1: [93x24] [history 895/50000, 1404064 bytes] %6
        #2: [94x23] [history 1/50000, 124457 bytes] %5
        #3: [188x48] [history 1164/50000, 4157881 bytes] %8 (active)
        #```
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

    panes=$(get_relevant_panes "$1")
    if [[ -z "$panes" ]]; then
        echo "No relevant panes found!" >&2
        exit 1
    fi

    for pane in $panes; do
        echo
        echo "****************"
        screenshot_pane "$pane" 2>/dev/null
        echo "****************"
        echo
    done
}

main "$@"
