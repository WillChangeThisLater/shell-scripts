#!/bin/bash

# Another weird script. Here's what's happening
#
# The 'bash_markdown' function adds markdown
# code blocks to LLM templates. You use it like this:
#
# [arch@archlinux shell-scripts]$ bash_markdown "ls | wc"
# ```bash
# > ls | wc
#       9       9     116
# ```
#
# Or more commonly, like this:
#
# ```prompt.sh
# #!/bin/bash
# 
# source ~/.bashrc
# 
# cat <<EOF
# Why does the following fail?
# 
# $(bash_markdown "aws s3 ls --profile bad_profile")
# EOF
# ```
#
# [arch@archlinux tmp]$ ./prompt.sh
# Why does the following fail?
# 
# ```bash
# > aws s3 ls --profile bad_profile
# 
# The config profile (bad_profile) could not be found
# ```

bash_markdown() {
    # Capture the entire command as a single string
    local cmd="$*"

    # Execute the command and store the output
    local output
    output=$(eval "$cmd" 2>&1)

    # Print the markdown-formatted text
    cat <<EOF
\`\`\`bash
> $cmd
$output
\`\`\`
EOF
}

declare -f bash_markdown
