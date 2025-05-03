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
  echo "  -a         Send the prompt to the tool called 'agent' instead of 'lm'."
}

# Default values
DEFAULT_PROMPT="[arch@archlinux shell-scripts]$"
DEFAULT_LIMIT=1000
DEBUG=false
USE_AGENT=false

# Initialize variables with default values
PROMPT="$DEFAULT_PROMPT"
LIMIT="$DEFAULT_LIMIT"

# Parse command-line options
while getopts ":p:l:dah" opt; do
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
    a)
      USE_AGENT=true
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
  TOOL="$1"
  shift

  if [ $# -eq 0 ]; then
    cat <<EOF
$(tmux capture-pane -p | tail -n "$LIMIT")


$PROMPT echo "consider the terminal output above. debug the error" | $TOOL
EOF
  else
    cat <<EOF
$(tmux capture-pane -p | tail -n "$LIMIT")


$PROMPT echo "$@" | $TOOL
EOF
  fi
}

# Determine the tool to use based on the -a option
TOOL="lm"
if [ "$USE_AGENT" = true ]; then
  TOOL="agent"
fi

# Execute main script logic
if [ "$DEBUG" = true ]; then
  getPrompt $TOOL "$@"
else
  getPrompt "$@" | $TOOL
fi
