#!/bin/bash
#
# clang_tidy.sh — статический анализ кода с помощью clang-tidy
# 
# Назначение:
#   Запуск clang-tidy с использованием
#   compile_commands.json, с поддержкой нескольких режимов анализа.
#
# Контракт:
#   - Если скрипт выполняется внутри Docker → выполняет нативный запуск clang-tidy
#   - Если скрипт выполняется на хосте → запускает анализ внутри Docker контейнера
#
# ВАЖНО:
#   clang-tidy требует compile_commands.json.
#   Для этого проект должен быть сконфигурирован с:
#     -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
#
#   На macOS дополнительно требуется:
#     -DCMAKE_OSX_SYSROOT="$(xcrun --show-sdk-path)"
#   Иначе возможны предупреждения на системных include.
#
# ============================================================================
# РЕЖИМЫ РАБОТЫ
#   light   (по умолчанию)
#     Минимальный, малошумный анализ реальных дефектов.
#   medium
#     Расширенный анализ (bugprone + часть performance).
#   strict
#     Жёсткий аудит (много предупреждений, использовать осознанно).
#
# ============================================================================
# ПРИМЕРЫ ЗАПУСКА
#   1) Запуск в режиме light (по умолчанию):
#       ./clang_tidy.sh
#   2) Запуск в режиме medium:
#       CLANG_TIDY_MODE=medium ./clang_tidy.sh
#   3) Запуск в режиме strict:
#       CLANG_TIDY_MODE=strict ./clang_tidy.sh
#   4) Анализ одного файла (любой режим):
#       ./clang_tidy.sh src/main.cpp
#
#       CLANG_TIDY_MODE=medium ./clang_tidy.sh src/snmp/snmp_agent.cpp
#
# ============================================================================
#
# Автор: BGM
#

set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/config.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/docker.sh"

# Проверка где выполняется скрипт (внутри контейнера или на хосте)
is_inside_docker() {
    [[ -f /.dockerenv ]]
}

# ---- Установка конфигурации ----
set_config() {
    # Режим clang-tidy:
    #   light   — минимальный, почти без шума (по умолчанию)
    #   medium  — расширенный анализ
    #   strict  — жёсткий аудит
    CLANG_TIDY_MODE=${CLANG_TIDY_MODE:-light}
}

# Команда для получения подсказки по генерации compile_commands.json
get_compile_commands_hint() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        cat <<EOF
cmake -S . -B ${BUILD_DIR} \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_OSX_SYSROOT="\$(xcrun --show-sdk-path)"
EOF
    else
        cat <<EOF
cmake -S . -B ${BUILD_DIR} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
EOF
    fi
}

# ---- Проверка условий ----
check_environment() {
    if [[ ! -f "${BUILD_DIR}/compile_commands.json" ]]; then
        log_error "clang-tidy requires ${BUILD_DIR}/compile_commands.json" "$LOG_INDENT"
        log_text "Project must be configured with compile commands export enabled." "$LOG_INDENT"
        log_text "Reconfigure project with:" "$LOG_INDENT"

        while IFS= read -r line; do
            log_text "$line" "$LOG_INDENT"
        done < <(get_compile_commands_hint)

        exit 1
    fi
}

# ---- Определение наборов проверок clang-tidy ----
set_clang_tidy_checks() {
    # ------------------------------------------------------------
    # CLANG_TIDY_CHECKS_LIGHT
    #
    # Назначение:
    #   Минимальный набор реальных дефектов.
    #   Можно запускать регулярно, почти без ложных срабатываний.
    #
    # Рекомендуется:
    #   • первый запуск
    #   • регулярная проверка перед релизом
    # ------------------------------------------------------------
    CLANG_TIDY_CHECKS_LIGHT=(
        bugprone-unused-*
        bugprone-empty-catch
        bugprone-narrowing-conversions
    )

    # ------------------------------------------------------------
    # CLANG_TIDY_CHECKS_MEDIUM
    #
    # Назначение:
    #   Расширенный анализ:
    #   • потенциальные ошибки
    #   • неочевидные проблемы с параметрами
    #   • базовые performance-рекомендации
    #
    # Рекомендуется:
    #   • ручной запуск
    #   • разбор по одному файлу
    # ------------------------------------------------------------
    CLANG_TIDY_CHECKS_MEDIUM=(
        bugprone-unused-*
        bugprone-empty-catch
        bugprone-narrowing-conversions
        bugprone-easily-swappable-parameters
        performance-unnecessary-copy-initialization
        performance-unnecessary-value-param
    )

    # ------------------------------------------------------------
    # CLANG_TIDY_CHECKS_STRICT
    #
    # Назначение:
    #   Жёсткий аудит кода.
    #   Может выдавать много шума и архитектурных замечаний.
    #
    # НЕ рекомендуется:
    #   • для регулярного использования
    #   • для автоматических проверок
    #
    # Использовать:
    #   • эпизодически
    #   • осознанно
    # ------------------------------------------------------------
    CLANG_TIDY_CHECKS_STRICT=(
        bugprone-*
        performance-*
        portability-*
    )

    # NOTE:
    # readability-*  — намеренно отключены (дублируют clang-format, много шума)
    # modernize-*    — намеренно отключены (проект C++11, важна совместимость)
    # cppcoreguidelines-* — намеренно отключены (слишком жёсткие правила)
    # misc-*         — намеренно отключены (слишком много ложных срабатываний)
}

# ---- Выбор профиля clang-tidy по режиму ----
select_clang_tidy_profile() {
    case "${CLANG_TIDY_MODE}" in
        light)
            CLANG_TIDY_CHECKS=("${CLANG_TIDY_CHECKS_LIGHT[@]}")
            ;;
        medium)
            CLANG_TIDY_CHECKS=("${CLANG_TIDY_CHECKS_MEDIUM[@]}")
            ;;
        strict)
            CLANG_TIDY_CHECKS=("${CLANG_TIDY_CHECKS_STRICT[@]}")
            ;;
        *)
            log_error "Unknown CLANG_TIDY_MODE='${CLANG_TIDY_MODE}'" "$LOG_INDENT"
            log_text "Valid values: light | medium | strict" "$LOG_INDENT"
            exit 1
            ;;
    esac
    log_info "clang-tidy mode: ${CLANG_TIDY_MODE}" "$LOG_INDENT"
}

# --- Формирование флагов для clang-tidy
set_clang_tidy_flags() {
    CLANG_TIDY_FLAGS=(
        "-checks=$(IFS=,; echo "${CLANG_TIDY_CHECKS[*]}")"
        "-warnings-as-errors="
        "-header-filter=^src/.*"
    )
}

# ---- Определение целевых файлов для анализа ----
set_targets() {
    TARGETS=()

    # Если файлы переданы аргументами — используем их
    if [[ $# -gt 0 ]]; then
        for file in "$@"; do
            if [[ ! -f "$file" ]]; then
                log_error "File not found: $file" "$LOG_INDENT"
                exit 1
            fi
            TARGETS+=("$file")
        done
        return
    fi

    # Иначе — анализируем все .cpp в src
    while IFS= read -r file; do
        TARGETS+=("$file")
    done < <(find src -type f -name '*.cpp')
}

run_clang_tidy() {
    local cmd_str
    printf -v cmd_str '%q ' "$@"
    log_debug "Running: ${cmd_str}" "$LOG_SUBINDENT"

    # Container environment (Ubuntu 24.04 + clang-tidy 18 + libstdc++ 13) emits
    # system-header diagnostics that are noise for user code analysis.
    # Filter only the summary lines ('N warning(s) generated', 'Suppressed N warning(s)',
    # and header-filter hint) while preserving actual diagnostics from checks.
    "$@" 2>&1 | awk '
        !/^[0-9]+ warnings? generated\.$/ &&
        !/^Suppressed [0-9]+ warnings? \([0-9]+ in non-user code\)\.$/ &&
        !/^Use -header-filter=.* to display errors from all non-system headers\. Use -system-headers to display errors from system headers as well\.$/
    '
    return "${PIPESTATUS[0]}"
}

run_clang_tidy_native() {
    log_stage "Clang-tidy (native)"
    run_clang_tidy \
        clang-tidy \
        "${TARGETS[@]}" \
        "${CLANG_TIDY_FLAGS[@]}" \
        -p "$BUILD_DIR"

    log_ok "clang-tidy completed" "$LOG_INDENT"
}

main() {
    set_config

    if is_inside_docker; then
        check_environment
        set_clang_tidy_checks
        select_clang_tidy_profile
        set_clang_tidy_flags
        set_targets "$@"
        run_clang_tidy_native
        return
    fi

    log_stage "Clang-tidy (Docker)"
    log_info "Running clang-tidy inside container" "$LOG_INDENT"
    docker_run ./scripts/clang_tidy.sh "$@"
}

main "$@"
