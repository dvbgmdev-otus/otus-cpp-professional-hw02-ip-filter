#!/usr/bin/env bash
#
# common.sh — общая инфраструктура для скриптов проекта
#
# Назначение:
#   - централизует конфигурацию (IMAGE_NAME, BUILD_DIR)
#   - предоставляет обёртки для работы с Docker
#   - инкапсулирует запуск контейнера (docker_run)
#
# Архитектура:
#   common.sh          — orchestration layer
#   ensure_docker.sh   — проверка Docker runtime
#   ensure_image.sh    — проверка/сборка Docker image
#
# Контракт:
#   - docker_run гарантирует:
#       • Docker доступен
#       • образ существует (или будет собран)
#       • корректный запуск контейнера (UID/GID, volume, TTY)
#
# Использование:
#   source scripts/common.sh
#   docker_run <command>
#
# Требования:
#   - bash
#   - docker
#
# Автор: BGM
#

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/logging.sh" || { 
    echo "ERROR: logging.sh not found at $SCRIPT_DIR"
    exit 1
}

LOG_INDENT=3
LOG_SUBINDENT=6

IMAGE_NAME="${IMAGE_NAME:-ip_filter_builder}"
BUILD_DIR="${BUILD_DIR:-build}"

# Проверяет доступность Docker окружения, при необходимости пытается его запустить (только на macOS)
ensure_docker() {
    if [[ ! -x "$SCRIPT_DIR/ensure_docker.sh" ]]; then
        log_error "ensure_docker.sh not found or not executable"
        exit 1
    fi
    "$SCRIPT_DIR/ensure_docker.sh"
}

# Проверяет наличие Docker образа, при необходимости собирает его
ensure_image() {
    if [[ ! -x "$SCRIPT_DIR/ensure_image.sh" ]]; then
        log_error "ensure_image.sh not found or not executable"
        exit 1
    fi
    "$SCRIPT_DIR/ensure_image.sh"
}

# Запускает команду внутри Docker контейнера
# Контракт:
#   - Если скрипт выполняется внутри Docker контейнера → выполняет команду напрямую
docker_run() {
    ensure_docker
    ensure_image

    log_info "Running container: $IMAGE_NAME" $LOG_INDENT

    local DOCKER_ARGS=(--rm --init)

    # TTY
    if [[ -t 1 && -t 0 ]]; then
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

    printf -v cmd_str "%q " "$@"
    log_debug "Command: docker run ${DOCKER_ARGS[*]} $IMAGE_NAME $cmd_str" $LOG_SUBINDENT

    docker run \
        "${DOCKER_ARGS[@]}" \
        "$IMAGE_NAME" \
        "$@"
}
