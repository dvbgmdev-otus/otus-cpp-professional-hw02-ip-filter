#!/usr/bin/env bash
#
# logging.sh — библиотека логирования для bash.
#
# Возможности:
#   - уровни: debug, info, warn, error
#   - фильтрация сообщений через LOG_LEVEL
#   - цветной вывод (при поддержке терминала)
#   - поддержка отступов
#   - вспомогательные функции: stage, success, separator
#
# Пример использования:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck disable=SC1091
#   source "$SCRIPT_DIR/logging.sh"
#   LOG_LEVEL=info
#   log_stage "Запуск скрипта"
#   log_warn "Предупреждение" 3
#   print_separator 3 50
#
# Автор: BGM

#region ====================== НАСТРОЙКА ЦВЕТОВ ======================
# Проверяем поддержку цветов для stdout и stderr
if [ -t 1 ] && [ -t 2 ]; then
    # И stdout и stderr идут в терминал - можно использовать цвета
    RED='\033[0;31m'    # ${RED}
    GREEN='\033[0;32m'  # ${GREEN}
    YELLOW='\033[0;93m' # ${YELLOW}
    CYAN='\033[0;36m'   # ${CYAN}
    BLUE='\033[0;34m'   # ${BLUE}
    BOLD='\033[1m'      # ${BOLD}
    NC='\033[0m'        # ${NC}
else
    # Вывод перенаправлен - цвета не используем
    RED=''
    GREEN=''
    YELLOW=''
    CYAN=''
    BLUE=''
    BOLD=''
    NC=''
fi
#endregion

# Уровни логирования
LOG_LEVEL=${LOG_LEVEL:-info}

# возможные значения: debug, info, warn, error
level_to_num() {
    case "$1" in
        debug) printf 0 ;;
        info)  printf 1 ;;
        warn)  printf 2 ;;
        error) printf 3 ;;
        *)     printf 1 ;;
    esac
}

CURRENT_LEVEL=$(level_to_num "$LOG_LEVEL")

# Функция для проверки, нужно ли логировать сообщение данного уровня
should_log() {
    local level_num
    level_num="$(level_to_num "$1")"
    [[ ${level_num} -ge ${CURRENT_LEVEL} ]] # логируем, если уровень сообщения выше или равен текущему уровню
}

# Внутренняя функция для логирования с цветами и отступами
_log() {
    local level="$1"
    local message="$2"
    local indent="${3:-0}"
    local prefix="${4:-}"
    local color="${5:-}"

    if ! should_log "${level}"; then
        return
    fi

    local fd=1
    case "${level}" in
        debug|warn|error) fd=2 ;; # stderr
        *)                fd=1 ;; # stdout
    esac

    local spaces 
    local text
    printf -v spaces '%*s' "${indent}" ''

    # формируем текст с отступом и префиксом
    if [[ -n "${prefix}" ]]; then
        text="${spaces}${prefix} ${message}"
    else
        text="${spaces}${message}"
    fi

    # вывод в нужный поток с цветом
    printf "%b%s%b\n" "${color}" "${text}" "${NC}" >&"$fd"
}
# =========================
# API для логирования сообщений разных уровней
# =========================

log_debug() {
    _log debug "$1" "${2:-}" "[DEBUG]"
}

log_info() {
    _log info "$1" "${2:-}" "[INFO]" "$CYAN" 
}
    
log_warn() {
    _log warn "$1" "${2:-}" "[WARN]" "$YELLOW"
}

log_error() {
    _log error "$1" "${2:-}" "[ERROR]" "$RED"
}

# Для выделения этапов выполнения
log_stage() {
   _log info "$1" "${2:-}" "===>" "$BLUE$BOLD"
}

# Для выделения успеха
log_success() {
    _log info "$1" "${2:-}" "[OK]" "$GREEN"
}

# Для обычного текста
log_text() {
    _log info "$1" "${2:-}"
}

# Функция для печати разделителя
print_separator() {
    if ! should_log info; then
        return
    fi
    local DEFAULT_TOTAL_WIDTH=70 # ширина по умолчанию для разделителя
    local DEFAULT_SEPARATOR_CHAR='-' # символ для разделителя
    local indent="${1:-0}"
    local total_width="${2:-${DEFAULT_TOTAL_WIDTH}}"
    local separator_char="${3:-${DEFAULT_SEPARATOR_CHAR}}"
    separator_char="${separator_char:0:1}" # берем только первый символ

    local content_width=$((total_width - indent))
    (( content_width < 1 )) && content_width=1

    local indent_str
    local line
    printf -v indent_str '%*s' "${indent}" ""
    printf -v line '%*s' "${content_width}" ""

    line=${line// /${separator_char}}

    printf "%s%s\n" "${indent_str}" "${line}"
}
