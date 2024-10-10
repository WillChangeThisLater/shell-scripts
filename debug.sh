#!/bin/bash

# You need to be in tmux for this to work
#
# Usage: ./debug.sh
#
# For instance:
#
# ```bash
# [arch@archlinux shell-scripts]$ echo "6 + 6" | dc
# dc: stack empty
# [arch@archlinux shell-scripts]$ debug
# Thinking...
# 
# The most recent error in the session is:
# 
# ```bash
# dc: stack empty
# ```
# 
# This error occurs when the `dc` command (an arbitrary precision calculator) is expecting more input but the stack is empty. In this case, the command `echo "6 + 6" | dc` is not providing the expected input format for `dc`.
# 
# To debug and fix this error:
# 
# 1. **Understand the `dc` command syntax:**
#    - `dc` processes commands and operands in a postfix manner, also known as Reverse Polish Notation (RPN). So, instead of `6 + 6`, it should be `6 6 +`.
# 
# 2. **Correct the command:**
#    - Change the command to `echo "6 6 + p" | dc`. The `p` at the end is a `dc` command to print the value at the top of the stack.
# 
# Here is the corrected command:
# 
# [arch@archlinux shell-scripts]$ echo "6 6 + p" | dc
# ```

set -euo pipefail

numLines=20
tmux capture-pane -pS -"$numLines" > /tmp/screenshot.txt
cat <<EOF
Thinking...

EOF

cat << EOF > /tmp/prompt.txt
Output from a terminal session is below.
I'd like you to help debug it

Step by step, walk through how to debug the most recent
error in the terminal session.
Be simple. Use clear language. Be concise. Provide commands
the user can run to debug and fix the error if you can.

Focus on the last error in the session. Mention relevant errors
from earlier in the session only if they are relevant.

If you think there are no errors, explain why you think that.

Some times the error might not be obvious, and you will
have to use reasoning to figure out what the confusion is.
For instance, although the bash output below has no explicit
errors, it is clear from the context that the user is confused
why the pgrep command for a PID returns no results, while a
combination of 'ps -a' and grep indicates the PID exists.

\`\`\`bash
[arch@archlinux link-embedder]$ pgrep 1757501
[arch@archlinux link-embedder]$ ps -a | grep 1757501
1757501 pts/11   00:00:00 sleep
\`\`\`

Just to reiterate: only focus on THE MOST RECENT error. 
For instance, if you see a session like this

\`\`\`bash
[arch@archlinux tmp]$ l
-bash: l: command not found
[arch@archlinux tmp]$ cat /var/sock/d
cat: /var/sock/d: No such file or directory
\`\`\`

ONLY focus on the most recent error (cat: /var/sock/d: No such file or directory)
Do NOT comment on the '-bash: l: command not found' error UNLESS it relates
to the (cat: /var/sock/d: No such file or directory) error in some way.

\`\`\`bash
$(cat /tmp/screenshot.txt)
\`\`\`
EOF

cat /tmp/prompt.txt | lm

