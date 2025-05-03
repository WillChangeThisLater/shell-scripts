#!/bin/bash

usage() {
  echo "Usage: script.sh [options]"
  echo "Options:"
  echo "  -p PROMPT  The prompt string to use."
  echo "             Defaults to '[arch@archlinux shell-scripts]$'."
  echo "  -l LIMIT   The number of lines to capture from the tmux pane."
  echo "             Defaults to 1000."
  echo "  -d         Enable debug mode. Sends the prompt to stdout instead of 'lm'."
  echo "  -h         Show this help message and exit."
}

# Default values
DEFAULT_PROMPT="[arch@archlinux shell-scripts]$"
DEFAULT_LIMIT=1000
DEBUG=false

# Initialize variables with default values
PROMPT="$DEFAULT_PROMPT"
LIMIT="$DEFAULT_LIMIT"

# Parse command-line options
while getopts ":p:l:dh" opt; do
  case $opt in
    p)
      PROMPT="$OPTARG"
      ;;
    l)
      LIMIT="$OPTARG"
      ;;
    d)
      DEBUG=true
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))

getPrompt() {
  if [ $# -eq 0 ]; then
    cat <<EOF
$(tmux capture-pane -p | tail -n "$LIMIT")


$PROMPT echo "consider the terminal output above. debug the error" | lm
EOF
  else
    cat <<EOF
$(tmux capture-pane -p | tail -n "$LIMIT")


$PROMPT echo "$@" | lm
EOF
  fi
}

# Execute main script logic
if [ "$DEBUG" = true ]; then
  getPrompt "$@"
else
  getPrompt "$@" | lm
fi
