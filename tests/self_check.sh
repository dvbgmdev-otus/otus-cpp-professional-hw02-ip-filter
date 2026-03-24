#!/usr/bin/env bash
set -eEuo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:${LINENO}: \"${BASH_COMMAND}\" failed" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../scripts/lib/config.sh"
# shellcheck disable=SC1091
source "$LIB_DIR/logging.sh"

EXPECTED_MD5="24e7a7b2270daee89c64d3ca5fb3da1a"

main() {
    local input_file="${PROJECT_ROOT}/data/ip_filter.tsv"
    local binary="${1:-${PROJECT_ROOT}/build/ip_filter}"
    local actual_md5

    if [[ ! -f "${input_file}" ]]; then
        log_error "Input file not found: ${input_file}"
        exit 1
    fi

    if [[ ! -x "${binary}" ]]; then
        log_error "Binary not found or not executable: ${binary}"
        exit 1
    fi

    actual_md5="$(
        "${binary}" < "${input_file}" | md5sum | awk '{print $1}'
    )"

    log_debug "Expected MD5: ${EXPECTED_MD5}"
    log_debug "Actual MD5:   ${actual_md5}"

    if [[ "${actual_md5}" != "${EXPECTED_MD5}" ]]; then
        log_error "Self-check failed"
        log_text "Expected: ${EXPECTED_MD5}"
        log_text "Actual:   ${actual_md5}"
        exit 1
    fi

    log_ok "Self-check passed"
    exit 0
}

main "$@"
