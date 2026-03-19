#!/usr/bin/env bash
#
# build.sh — сборка проекта (локально или в Docker)
#
# Контракт:
#   - Если скрипт выполняется внутри Docker → выполняет нативную сборку (cmake)
#   - Если скрипт выполняется на хосте → запускает сборку внутри Docker контейнера
#
# Особенности:
#   - Использует docker_run из common.sh
#
# Переменные окружения:
#   BUILD_DIR — директория сборки (по умолчанию: build)
#
# Коды возврата:
#   0 — успешная сборка
#   1 — ошибка сборки или инфраструктуры
#
# Автор: BGM

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/common.sh" || { 
    echo "ERROR: common.sh not found at $SCRIPT_DIR"
    exit 1
}

# Проверка где выполняется скрипт (внутри контейнера или на хосте)
is_inside_docker() {
    [[ -f /.dockerenv ]]
}

# Чистая сборка
build_native() {
    log_stage "Build (native)"
    log_info "Configuring project" "$LOG_INDENT"
    cmake -S . -B "$BUILD_DIR"

    log_info "Building project" "$LOG_INDENT"
    cmake --build "$BUILD_DIR"

    log_ok "Build completed" "$LOG_INDENT"
}

# Главная функция
main() {

    if is_inside_docker; then
        build_native
        return
    fi

    log_stage "Build (Docker)"
    log_info "Running build inside container" "$LOG_INDENT"

    docker_run ./scripts/build.sh
}

main "$@"
