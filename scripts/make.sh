#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="ip_filter_builder"

BUILD_CMD="
rm -rf build &&
cmake -S . -B build &&
cmake --build build &&
ctest --test-dir build
"

echo "==> Detecting OS..."
OS="$(uname -s)"

ensure_docker_running_macos() {
    echo "==> macOS detected"

    if ! command -v colima >/dev/null 2>&1; then
        echo "ERROR: colima not installed. Install via: brew install colima"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "==> Docker not running. Starting colima..."
        colima start
    else
        echo "==> Docker already running"
    fi
}

ensure_docker_running_linux() {
    echo "==> Linux detected"

    if ! docker info >/dev/null 2>&1; then
        echo "ERROR: Docker daemon is not running"
        exit 1
    fi
}

case "$OS" in
    Darwin)
        ensure_docker_running_macos
        ;;
    Linux)
        ensure_docker_running_linux
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "==> Building Docker image (if needed)..."
docker build -t "$IMAGE_NAME" docker

echo "==> Running build inside container..."
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$(pwd)":/app \
    -w /app \
    "$IMAGE_NAME" \
    bash -c "$BUILD_CMD"

echo "==> Build finished successfully"