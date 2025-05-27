#!/bin/bash

set -euo pipefail

MAX_CONCURRENCY=10
DEFAULT_PROMPT="Summarize the following information in a succinct, useful way"

prompt="$DEFAULT_PROMPT"

# Function to handle command-line arguments
parse_args() {
    while getopts ":p:" opt; do
        case $opt in
            p)
                prompt="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                exit 1
                ;;
        esac
    done
}

collect_summaries() {
    # GNU parallel returns the number of failed processes
    # as its exit status. the reason I'm unsetting '-e' here
    # is to prevent one bad URI from ruining the synth
    #
    # that said, this can potentially mask more serious errors
    # consider changing this at some point
    set +e
    parallel -j "$MAX_CONCURRENCY" echo "{}" \| summarize
    set -e
}

main() {
    parse_args "$@"
    collect_summaries | lm --prompt "$prompt"
}

main "$@"
