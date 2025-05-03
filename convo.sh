#!/bin/bash

#PROMPT='[arch@archlinux shell-scripts]$'
#LIMIT=1000
#
#cat <<EOF | lm
#$(tmux capture-pane -p | tail -n "$LIMIT")
#
#$PROMPT echo "$@" | lm
#EOF

# Set default values
#DEFAULT_PROMPT='[arch@archlinux shell-scripts]$'
#DEFAULT_LIMIT=1000
#
## Function to display usage
#usage() {
#  echo "Usage: $0 [PROMPT] [LIMIT]"
#  echo
#  echo "Optional arguments:"
#  echo "  PROMPT     The prompt string to use. Defaults to '[arch@archlinux shell-scripts]$'."
#  echo "  LIMIT      The number of lines to capture from the tmux pane. Defaults to 1000."
#  echo "  -h         Show this help message and exit."
#}
#
## Check for -h option
#if [[ "$1" == "-h" ]]; then
#  usage
#  exit 0
#fi
#
## Use provided arguments or defaults
#PROMPT="${1:-$DEFAULT_PROMPT}"
#LIMIT="${2:-$DEFAULT_LIMIT}"
#
## Execute main script logic
#cat <<EOF | lm
#$(tmux capture-pane -p | tail -n "$LIMIT")
#
#$PROMPT echo "$@" | lm
#EOF

# Set default values
DEFAULT_PROMPT='[arch@archlinux shell-scripts]$'
DEFAULT_LIMIT=1000

# Function to display usage
usage() {
  echo "Usage: $0 [options]"
  echo
  echo "Optional arguments:"
  echo "  -p PROMPT  The prompt string to use."
  echo "             Defaults to '[arch@archlinux shell-scripts]$'."
  echo "  -l LIMIT   The number of lines to capture from the tmux pane."
  echo "             Defaults to 1000."
  echo "  -h         Show this help message and exit."
}

# Initialize variables with default values
PROMPT="$DEFAULT_PROMPT"
LIMIT="$DEFAULT_LIMIT"

# Parse command-line options
while getopts ":p:l:h" opt; do
  case $opt in
    p)
      PROMPT="$OPTARG"
      ;;
    l)
      LIMIT="$OPTARG"
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

# Execute main script logic
cat <<EOF | lm
$(tmux capture-pane -p | tail -n "$LIMIT")

$PROMPT echo "$@" | lm
EOF
