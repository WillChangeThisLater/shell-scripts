#!/bin/bash

set -exo pipefail

# Check if the required argument is provided
if [ -z "$1" ]; then
  echo "Usage: tmpopen <S3 path>"
  exit 1
fi

set -u

S3_PATH=$1

# Generate a temporary directory name and make sure it gets cleaned up
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
aws s3 cp "$S3_PATH" "$TMP_DIR/$(basename "$S3_PATH")"

# Open the downloaded file
# TODO: this should use 'open' on mac
xdg-open "$TMP_DIR/$(basename "$S3_PATH")"

# Give the system some time to open the file
sleep 5
