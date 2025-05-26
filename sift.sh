#!/bin/bash

set -euo pipefail

# 'sift' is a combination of 'vault' and 'relevant'
#
# 'vault' performs a vector search to determine which
# documents are the most similar to a given query
#
# 'filter' is a tool which determines if documents are
# relevant to a given query
#
# the idea here is to use 'vault' to get a rough list of
# documents that closely match your query, then use 'relevant'
# to filter that query
#
# ```bash
# $ sift "the coolest shell scripts you can find. the only way for a shell script to qualify as 'cool' is to be extremely, extremely clever" 10
# /Users/paul.wendt/personal-repos/shell-scripts/remote-setup.sh
# /Users/paul.wendt/personal-repos/shell-scripts/whisper.sh
# /Users/paul.wendt/personal-repos/shell-scripts/markdown.sh
# /Users/paul.wendt/personal-repos/shell-scripts/utils.sh
# /Users/paul.wendt/personal-repos/shell-scripts/netutils.sh
# /Users/paul.wendt/personal-repos/shell-scripts/bf.sh
# ```
#
# ```bash
# $ sift "the weakest, least rizzy shell scripts you can find brah. the only way for a shell script to qualify as 'lame' is to be extremely, extremely boring and not kewl" 10
# $ # :)
# ```
#

search_vault_relevance() {
  # Check if the query (first argument) is provided
  set +u
  if [ -z "$1" ]; then
    echo "Usage: search_vault_relevance <query> [top-k]"
    return 1
  fi
  set -u

  # Assign the query
  QUERY="$1"

  # Assign --top-k value if provided, else default to 5
  TOP_K=${2:-5}

  # Perform the search and filter for relevance
  vault search "$QUERY" --top-k "$TOP_K" | filter "$QUERY"
}

search_vault_relevance "$@"
