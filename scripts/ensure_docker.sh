#!/usr/bin/env bash

set -euo pipefail

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

        echo "==> Waiting for Docker daemon..."

        until docker info >/dev/null 2>&1; do
            sleep 1
        done
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