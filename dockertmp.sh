#!/bin/bash

# Function to generate a random hash
generate_random_hash() {
  echo $(openssl rand -hex 12)
}

# Check if Dockerfile path argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <Dockerfile>"
  exit 1
fi

# Generate random hash
RANDOM_HASH=$(generate_random_hash)

# Build Docker image
docker build -t "$RANDOM_HASH" -f "$1" . || { echo "Failed to build the Docker image"; exit 1; }

# Run Docker container
docker run --rm -it "$RANDOM_HASH" /bin/bash

# Remove the Docker image silently
docker rmi "$RANDOM_HASH" > /dev/null 2>&1
