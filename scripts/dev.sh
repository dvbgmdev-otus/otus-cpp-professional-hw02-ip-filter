#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="ip_filter_builder"

BUILD_CMD="
rm -rf build &&
cmake -S . -B build &&
cmake --build build &&
ctest --test-dir build --output-on-failure
"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect if running inside container
if [ -f /.dockerenv ]; then
    echo "==> Running inside container"
    bash -c "$BUILD_CMD"
    exit 0
fi

echo "==> Checking Docker environment..."
"$SCRIPT_DIR/ensure_docker.sh"

echo "==> Building Docker image (if needed)..."
#export DOCKER_BUILDKIT=1
docker build -t "$IMAGE_NAME" ./docker

OS="$(uname -s)"

echo "==> Running build inside container..."

if [[ "$OS" == "Linux" ]]; then
    docker run --rm --init \
        -u "$(id -u):$(id -g)" \
        -v "$(pwd -P)":/app \
        -w /app \
        "$IMAGE_NAME" \
        bash -c "$BUILD_CMD"
else
    docker run --rm --init \
        -v "$(pwd -P)":/app \
        -w /app \
        "$IMAGE_NAME" \
        bash -c "$BUILD_CMD"
fi

echo "==> Build finished successfully"