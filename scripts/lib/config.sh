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

    # корневая директория со всеми скриптами
    SHELL_DIR="$(cd "$LIB_DIR/.." && pwd -P)"    
    # shellcheck disable=SC2034
    readonly SHELL_DIR

    # Имя Docker образа (по умолчанию "ip_filter_builder")
    readonly IMAGE_NAME="${IMAGE_NAME:-ip_filter_builder}"

    # Директория для сборки (по умолчанию "build" в корне проекта)
    readonly BUILD_DIR="${BUILD_DIR:-build}"
    
    # Отступы для логирования (используются в других скриптах)
    # shellcheck disable=SC2034
    readonly LOG_INDENT=3
    # shellcheck disable=SC2034
    readonly LOG_SUBINDENT=6
fi
