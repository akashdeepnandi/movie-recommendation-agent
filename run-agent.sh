#!/usr/bin/env bash
set -euo pipefail

INTERVAL_SECONDS="${INTERVAL_SECONDS:-300}"

while true; do
    echo "Running movie recommendation workflow..."

    result=$(
      opencode run --format json "Run the movie recommendation workflow." |
      jq -r 'select(.type == "text") | .part.text'
    )

    status=$(echo "$result" | jq -r '.status')

    if [[ "$status" == "success" ]]; then
        # JUST A SIMPLE ECHO COMMAND BUT CAN BE REPLACED WITH ANY NOTIFICATION CLI
        echo "SUCCESS, find the recommendation:"
        echo "$result" | jq
    else
        echo "FAILED, result: "
        echo "$result" | jq
    fi

    echo "Sleeping for ${INTERVAL_SECONDS}s..."
    sleep "$INTERVAL_SECONDS"
done
