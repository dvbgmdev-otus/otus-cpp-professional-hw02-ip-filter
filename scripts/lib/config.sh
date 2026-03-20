#!/usr/bin/env bash

# config.sh — конфигурация проекта (shared variables)

# Предотвращаем выполнение этого файла напрямую
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    printf "This script is a library and should not be executed directly\n" >&2
    exit 1
fi

# Защита от повторного включения
if [[ -z "${__CONFIG_SH_INCLUDED:-}" ]]; then
    readonly __CONFIG_SH_INCLUDED=1

    # директория, в которой лежат все библиотеки (scripts/lib)
    LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" 
    # shellcheck disable=SC2034
    readonly LIB_DIR

    # директория со скриптами (scripts)
    SHELL_DIR="$(cd "$LIB_DIR/.." && pwd -P)"
    # shellcheck disable=SC2034
    readonly SHELL_DIR

    # корень проекта
    PROJECT_ROOT="$(cd "$SHELL_DIR/.." && pwd -P)"
    # shellcheck disable=SC2034
    readonly PROJECT_ROOT

    # Имя Docker образа
    # shellcheck disable=SC2034
    readonly IMAGE_NAME="ip_filter_builder"

    # Директория для сборки проекта
    # shellcheck disable=SC2034
    readonly BUILD_DIR="$PROJECT_ROOT/build"
    
    # Отступы для логирования (используются в других скриптах)
    # shellcheck disable=SC2034
    readonly LOG_INDENT=3
    # shellcheck disable=SC2034
    readonly LOG_SUBINDENT=6
fi
