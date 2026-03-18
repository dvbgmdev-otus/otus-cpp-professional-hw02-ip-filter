#!/usr/bin/env bash

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/logging.sh"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh"

########################################
# Detect environment
########################################

is_inside_docker() {
    [[ -f /.dockerenv ]]
}

########################################
# Pure build (cmake only)
########################################

build_native() {
    log_stage "Build (native)"
    log_info "Configuring project" 3
    cmake -S . -B "$BUILD_DIR"

    log_info "Building project" 3
    cmake --build "$BUILD_DIR"

    log_success "Build completed" 3
}

########################################
# Main
########################################

main() {

    if is_inside_docker; then
        build_native
        return
    fi

    log_stage "Build (Docker)"

    ensure_docker

    log_info "Running build inside container" 3

    docker_run bash -c "./scripts/build.sh"
}

main "$@"
