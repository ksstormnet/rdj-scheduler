#!/usr/bin/env bash
#######################################
# Logging Module
# Last Updated: 2025-01-21
#
# Core logging functionality providing standardized log levels,
# message formatting, and file output capabilities.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Log level definitions (only if not already defined)
if [[ -z "${LOG_LEVEL_ERROR:-}" ]]; then
    declare -g LOG_LEVEL_ERROR=0
    declare -g LOG_LEVEL_WARN=1
    declare -g LOG_LEVEL_INFO=2
    declare -g LOG_LEVEL_DEBUG=3
fi

# Default log file location if not set
: "${LOG_FILE:=logs/app.log}"

#######################################
# Initialize logging with specified configuration
# Globals:
#   LOG_FILE
#   LOG_LEVEL
# Arguments:
#   None
# Returns:
#   0 if initialization succeeds, 1 if fails
#######################################
init_logging() {
    # Set default log level if not specified
    LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

    # Ensure log directory exists
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    mkdir -p "$log_dir" || {
        echo "Error: Failed to create log directory: $log_dir" >&2
        return 1
    }

    # Create or clear log file
    : > "$LOG_FILE" || {
        echo "Error: Failed to initialize log file: $LOG_FILE" >&2
        return 1
    }

    return 0
}

#######################################
# Internal logging function
# Globals:
#   LOG_FILE
#   LOG_LEVEL
# Arguments:
#   $1 - Message level (0-3)
#   $2 - Level label (ERROR, WARN, etc.)
#   $3 - Message to log
# Returns:
#   None
#######################################
_log() {
    local level=$1
    local label=$2
    local message=$3
    local timestamp

    # Check if message should be logged based on level
    [[ $level -gt ${LOG_LEVEL:-$LOG_LEVEL_INFO} ]] && return 0

    # Generate ISO 8601 timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Write to log file
    printf "[%s] [%s] %s\n" "$timestamp" "$label" "$message" >> "$LOG_FILE"
}

#######################################
# Log debug message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_debug() {
    _log $LOG_LEVEL_DEBUG "DEBUG" "$1"
}

#######################################
# Log info message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_info() {
    _log $LOG_LEVEL_INFO "INFO" "$1"
}

#######################################
# Log warning message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_warn() {
    _log $LOG_LEVEL_WARN "WARN" "$1"
}

#######################################
# Log error message
# Arguments:
#   $1 - Message to log
# Returns:
#   None
#######################################
log_error() {
    _log $LOG_LEVEL_ERROR "ERROR" "$1"
}
