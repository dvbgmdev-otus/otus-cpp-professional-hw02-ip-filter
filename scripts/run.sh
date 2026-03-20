#!/usr/bin/env bash
#
# run.sh — запуск приложения с автосборкой при необходимости
#
# Контракт:
#   - Если скрипт выполняется внутри Docker → проверяет бинарник и запускает его нативно
#   - Если скрипт выполняется на хосте → запускает выполнение внутри Docker контейнера
#
# Поведение:
#   - Если бинарник отсутствует или не исполняемый — запускает scripts/build.sh
#   - После успешной сборки запускает бинарник
#   - Аргументы run.sh пробрасываются в бинарник
#
# Коды возврата:
#   0 — успешный запуск
#   1 — ошибка сборки/запуска

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/config.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/docker.sh"

BIN_PATH="$BUILD_DIR/ip_filter"

is_inside_docker() {
    [[ -f /.dockerenv ]]
}

ensure_build() {
    if [[ -x "$BIN_PATH" ]]; then
        log_info "Binary found: $BIN_PATH" "$LOG_INDENT"
        return
    fi

    log_warn "Binary not found. Starting build" "$LOG_INDENT"
    "$SHELL_DIR/build.sh"

    if [[ ! -x "$BIN_PATH" ]]; then
        log_error "Binary was not produced: $BIN_PATH" "$LOG_INDENT"
        return 1
    fi

    log_ok "Binary is ready: $BIN_PATH" "$LOG_INDENT"
}

run_native() {
    log_stage "Run (native)"
    ensure_build

    log_info "Starting binary" "$LOG_INDENT"
    log_debug "Running: $BIN_PATH $*" "$LOG_SUBINDENT"
    "$BIN_PATH" "$@"
}

main() {
    if is_inside_docker; then
        run_native "$@"
        return
    fi

    log_stage "Run (Docker)"
    log_info "Running application inside container" "$LOG_INDENT"
    docker_run ./scripts/run.sh "$@"
}

main "$@"
