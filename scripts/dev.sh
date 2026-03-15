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

usage() {
cat <<EOF
Usage: ./scripts/dev.sh <command>

Commands:
  build     Build project inside Docker
  test      Run tests
  clean     Remove build directory
  image     Rebuild Docker image
  help      Show this help
EOF
}

########################################
# Build inside container
########################################

build_project() {
    log "Configuring project"
    cmake -S . -B "$BUILD_DIR"

    log "Building project"
    cmake --build "$BUILD_DIR"
}

run_tests() {
    log "Running tests"
    ctest --test-dir "$BUILD_DIR" --output-on-failure
}

run_inside_container() {
    log "Running inside container"

    case "${1:-build}" in
        build)
            build_project
            run_tests
            ;;
        test)
            run_tests
            ;;
        *)
            echo "Unknown internal command"
            exit 1
            ;;
    esac
}

########################################
# Host side
########################################

ensure_docker() {
    log "Checking Docker environment..."
    "$SCRIPT_DIR/ensure_docker.sh"
}

build_image() {
    log "Building Docker image..."
    docker build -t "$IMAGE_NAME" ./docker
}

run_container() {

    local command="${1:-build}"

    log "Running inside container: $command"

    local os
    os="$(uname -s)"

    if [[ "$os" == "Linux" ]]; then
        docker run --rm --init \
            -u "$(id -u):$(id -g)" \
            -v "$(pwd -P)":/app \
            -w /app \
            "$IMAGE_NAME" \
            bash scripts/dev.sh internal "$command"
    else
        docker run --rm --init \
            -v "$(pwd -P)":/app \
            -w /app \
            "$IMAGE_NAME" \
            bash scripts/dev.sh internal "$command"
    fi
}

clean() {
    log "Cleaning build directory"
    rm -rf "$BUILD_DIR"
}

########################################
# Main
########################################

main() {

    local command="${1:-build}"

    # detect container execution
    if [[ "$command" == "internal" ]]; then
        shift
        run_inside_container "$@"
        return
    fi

    case "$command" in
        build|-b|--build)
            ensure_docker
            run_container build
            ;;

        test|-t|--test)
            ensure_docker
            run_container test
            ;;

        clean|-c|--clean)
            clean
            ;;

        image|-i|--image)
            ensure_docker
            build_image
            ;;

        help|-h|--help)
            usage
            exit 0
            ;;

        *)
            usage
            exit 1
            ;;
    esac

    log "Done"
}

main "$@"
