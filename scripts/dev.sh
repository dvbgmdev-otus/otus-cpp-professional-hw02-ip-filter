#!/usr/bin/env bash

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

IMAGE_NAME="ip_filter_builder"
BUILD_DIR="build"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

########################################
# Utility
########################################

log() {
    local BLUE="\033[34m"
    local CLEAR="\033[0m"
    printf "%b===> %s%b\n" "$BLUE" "$*" "$CLEAR"
}

########################################
# Build inside container
########################################

build_project() {
    rm -rf "$BUILD_DIR"

    cmake -S . -B "$BUILD_DIR"
    cmake --build "$BUILD_DIR"

    ctest --test-dir "$BUILD_DIR" --output-on-failure
}

run_inside_container() {
    log "Running inside container"
    build_project
}

########################################
# Host side
########################################

ensure_docker() {
    log "Checking Docker environment..."
    "$SCRIPT_DIR/ensure_docker.sh"
}

build_image() {
    log "Building Docker image (if needed)..."
    docker build -t "$IMAGE_NAME" ./docker
}

run_container() {
    log "Running build inside container..."

    local os
    os="$(uname -s)"

    if [[ "$os" == "Linux" ]]; then
        docker run --rm --init \
            -u "$(id -u):$(id -g)" \
            -v "$(pwd -P)":/app \
            -w /app \
            "$IMAGE_NAME" \
            bash scripts/dev.sh internal-build
    else
        docker run --rm --init \
            -v "$(pwd -P)":/app \
            -w /app \
            "$IMAGE_NAME" \
            bash scripts/dev.sh internal-build
    fi
}

########################################
# Main
########################################

main() {

    # detect container execution
    if [ -f /.dockerenv ]; then
        run_inside_container
        return
    fi

    ensure_docker
    build_image
    run_container

    log "Build finished successfully"
}

main "$@"
