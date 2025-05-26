#!/bin/bash

IMAGE=${1:-ubuntu}
OUTPUT_FILE="docker-debug-output.log"

(
echo "Debugging Docker Error for image: $IMAGE"
date
echo ""

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install it first."
    exit 1
fi

echo "> docker run -it $IMAGE"
docker run -it $IMAGE 2>&1

if sudo systemctl is-active --quiet docker.service && systemctl is-active --quiet containerd; then
    echo "Docker and Containerd services are running."
else
    echo "One or both of Docker and Containerd services are not running."
fi

echo "> sudo journalctl -u docker.service --since \"5 minutes ago\""
sudo journalctl -u docker.service --output=short-precise --since "5 minutes ago" 2>&1 | tail -n 100

echo "> sudo journalctl -u containerd --since \"5 minutes ago\""
sudo journalctl -u containerd --output=short-precise --since "5 minutes ago" 2>&1 | tail -n 100

) | tee "$OUTPUT_FILE"
