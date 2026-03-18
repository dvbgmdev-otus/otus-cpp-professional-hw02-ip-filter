#!/usr/bin/env bash

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

########################################
# Paths
########################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/logging.sh"

########################################
# Config
########################################

IMAGE_NAME="${IMAGE_NAME:-ip_filter_builder}"
BUILD_DIR="${BUILD_DIR:-build}"

########################################
# Docker helpers
########################################

# Проверяет доступность Docker окружения, при необходимости пытается его запустить (только на macOS)
ensure_docker() {
    "$SCRIPT_DIR/ensure_docker.sh"
}

docker_image_exists() {
    docker image inspect "$IMAGE_NAME" >/dev/null 2>&1
}

ensure_image() {
    if ! docker_image_exists; then
        log_warn "Docker image '$IMAGE_NAME' not found" 3
        log_text "Run: ./scripts/image.sh" 6
        exit 1
    fi
}

########################################
# Docker run wrapper
########################################

docker_run() {
    ensure_image

    log_info "Running container: $IMAGE_NAME" 3

    local DOCKER_ARGS=(--rm --init)

    # TTY
    if [[ -t 1 ]]; then
        DOCKER_ARGS+=(-it)
    fi

    # Linux UID mapping
    if [[ "$(uname -s)" == "Linux" ]]; then
        DOCKER_ARGS+=(-u "$(id -u):$(id -g)")
    fi

    # volumes
    DOCKER_ARGS+=(
        -v "$(pwd -P)":/app
        -w /app
    )

    docker run \
        "${DOCKER_ARGS[@]}" \
        "$IMAGE_NAME" \
        "$@"
}
