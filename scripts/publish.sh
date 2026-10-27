#!/usr/bin/env bash
# Builds the notes-web image and publishes it to the local registry.
# Usage: bash scripts/publish.sh
set -euo pipefail

IMAGE="notes-web"
REGISTRY="localhost:5050"

docker build -t "$IMAGE:latest" .
docker push "$IMAGE:latest"
