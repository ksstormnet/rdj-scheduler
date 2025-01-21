#!/bin/bash
#######################################
# Logging Functions
# Last Updated: 2025-01-21
#
# Core logging functionality providing debug, info,
# warning, and error logging capabilities.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Configuration
declare -g DEBUG=${DEBUG:-0}
declare -g TEST_LOG_FILE=${TEST_LOG_FILE:-}
declare -g LOG_FILE=${LOG_FILE:-logs/app.log}

# Internal helper function to write log messages
_log_write() {
    local level="$1"
    local msg="$2"
    local log_line="[${level}] ${msg}"
    
    # Determine target file
    local target_file="${TEST_LOG_FILE:-${LOG_FILE}}"
    
    # Write the message
    echo "${log_line}" >> "${target_file}"
    
    return 0
}

# Debug logging - only if DEBUG is enabled
debug() {
    local msg="${1:-}"
    if [[ "${DEBUG}" -eq 1 ]]; then
        _log_write "DEBUG" "${msg}"
    fi
    return 0
}

# Info logging
info() {
    local msg="${1:-}"
    _log_write "INFO" "${msg}"
    return 0
}

# Warning logging
warning() {
    local msg="${1:-}"
    _log_write "WARNING" "${msg}"
    return 0
}

# Error logging
error() {
    local msg="${1:-}"
    _log_write "ERROR" "${msg}"
    return 0
}
