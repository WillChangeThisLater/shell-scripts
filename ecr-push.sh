#!/bin/bash

set -euxo pipefail

maybe_create_repository() {
    if ! aws ecr describe-repositories --repository-names "$1" > /dev/null 2>&1; then
        read -p "Repository $1 does not exist. Do you want to create it? (y/n): " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          aws ecr create-repository --repository-name "$1" >/dev/null 2>&1
        else
          echo "Repository $1 does not exist. Exiting."
          exit 1
        fi
    fi
}

# Initialize variables
AWS_REGION="us-east-1"
DOCKERFILE=""
REPOSITORY_NAME=""

# Parse arguments
while getopts "d:r:" opt; do
  case $opt in
    d) DOCKERFILE="$OPTARG" ;;
    r) REPOSITORY_NAME="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
  esac
done

# Check if required arguments are provided
if [ -z "$DOCKERFILE" ] || [ -z "$REPOSITORY_NAME" ]; then
  echo "Usage: $0 -d <Dockerfile> -r <repository-name>"
  exit 1
fi

PLATFORMS="linux/amd64" # Adjust as needed

# Login to ECR
ACCOUNT_NUMBER=$(aws sts get-caller-identity --query 'Account' --output text)
REGISTRY="$ACCOUNT_NUMBER.dkr.ecr.$AWS_REGION.amazonaws.com"
aws ecr get-login-password | docker login --username AWS --password-stdin "$REGISTRY"

maybe_create_repository "$REPOSITORY_NAME"
IMAGE="$REGISTRY/$REPOSITORY_NAME"

# Build and push the image to ECR
docker build --tag $IMAGE:latest --file $DOCKERFILE --platform $PLATFORMS .
docker push "$IMAGE:latest"

