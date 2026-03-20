#!/usr/bin/env bash
#
# test.sh — запуск тестов с автосборкой при необходимости
#
# Контракт:
#   - Если скрипт выполняется внутри Docker → проверяет артефакты тестов и запускает их нативно
#   - Если скрипт выполняется на хосте → запускает выполнение внутри Docker контейнера
#
# Поведение:
#   - Если тестовые артефакты отсутствуют — запускает scripts/build.sh
#   - После успешной сборки запускает тесты через ctest
#   - Аргументы test.sh пробрасываются в ctest
#
# Коды возврата:
#   0 — все тесты успешно пройдены
#   1 — ошибка сборки/запуска тестов

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/config.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/docker.sh"

TEST_BINARY_PATH="$BUILD_DIR/ip_filter_gtest"
CTEST_FILE_PATH="$BUILD_DIR/CTestTestfile.cmake"

is_inside_docker() {
    [[ -f /.dockerenv ]]
}

ensure_test_build() {
    if [[ -x "$TEST_BINARY_PATH" && -f "$CTEST_FILE_PATH" ]]; then
        log_info "Test artifacts found: $TEST_BINARY_PATH" "$LOG_INDENT"
        return
    fi

    log_warn "Test artifacts not found. Starting build" "$LOG_INDENT"
    "$SHELL_DIR/build.sh"

    if [[ ! -x "$TEST_BINARY_PATH" || ! -f "$CTEST_FILE_PATH" ]]; then
        log_error "Test artifacts were not produced in: $BUILD_DIR" "$LOG_INDENT"
        return 1
    fi

    log_ok "Test artifacts are ready" "$LOG_INDENT"
}

run_native() {
    log_stage "Test (native)"
    ensure_test_build

    log_info "Running tests" "$LOG_INDENT"
    log_debug "Running: ctest --test-dir \"$BUILD_DIR\" --output-on-failure $*" "$LOG_SUBINDENT"
    ctest --test-dir "$BUILD_DIR" --output-on-failure "$@"
}

main() {
    if is_inside_docker; then
        run_native "$@"
        return
    fi

    log_stage "Test (Docker)"
    log_info "Running tests inside container" "$LOG_INDENT"
    docker_run ./scripts/test.sh "$@"
}

main "$@"
