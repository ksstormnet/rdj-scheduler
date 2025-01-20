#!/bin/bash
# Simple logging module that writes to local file
# Supports basic log levels and overwrites log file on initialization

# Enable strict mode
set -euo pipefail

# Log levels (exportable for testing)
# Only declare log levels if not already set
[[ -z "${LOG_LEVEL_ERROR:-}" ]] && declare -gr LOG_LEVEL_ERROR=0
[[ -z "${LOG_LEVEL_WARN:-}" ]] && declare -gr LOG_LEVEL_WARN=1
[[ -z "${LOG_LEVEL_INFO:-}" ]] && declare -gr LOG_LEVEL_INFO=2
[[ -z "${LOG_LEVEL_DEBUG:-}" ]] && declare -gr LOG_LEVEL_DEBUG=3

# Export log levels for testing
export LOG_LEVEL_ERROR LOG_LEVEL_WARN LOG_LEVEL_INFO LOG_LEVEL_DEBUG

# Default configuration
# Default to INFO level if not set
: "${LOG_LEVEL:=$LOG_LEVEL_INFO}"
# Set default log format if not provided
: "${LOG_FORMAT:=[%datetime%] [%level%] %message%}"
# Export for use in other scripts
export LOG_LEVEL LOG_FORMAT
# Get current timestamp for log messages
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Format a log message with timestamp and level
# Format log message with timestamp and level
# Args:
#   $1: log level name
#   $2: message to log
table_format() {
    local -r message="$1"
    # Format message with proper padding and borders 
    printf "  | %-50s |\n" "$message"
}

format_log_message() {
    local -r level="$1"
    local -r message="$2"
    local ts
    local formatted

    ts=$(get_timestamp)
    formatted="${LOG_FORMAT//%datetime%/$ts}"
    formatted="${formatted//%level%/$level}"
    formatted="${formatted//%message%/$message}"
    
    # Add DEBUG: prefix only for debug level when not in production
    # Show DEBUG prefix only at debug log level
    if [[ "$level" == "DEBUG" ]] && [[ "$LOG_LEVEL" -eq "$LOG_LEVEL_DEBUG" ]]; then
        formatted="DEBUG: $formatted"
    fi
    echo "$formatted"
}

# Main logging function
log_message() {
    if [[ $# -ne 3 ]]; then
        echo "ERROR: Invalid number of arguments to log_message" >&2
        return 1
    fi

    local -r level="$1"
    local -r level_name="$2"
    local -r message="$3"

    # Validate inputs
    if [[ -z "$message" ]]; then
        echo "ERROR: Empty message passed to log_message" >&2
        return 1
    fi

    # Check if this log level should be logged
    # Skip if message level is above configured level
    if [[ "${level}" -gt "${LOG_LEVEL:-0}" ]]; then
        return 0
    fi

    # Format and write the message
    local formatted_message
    formatted_message=$(format_log_message "$level_name" "$message")

    if [[ -n "$LOG_FILE" ]]; then
        echo "$formatted_message" >> "$LOG_FILE" || {
            echo "ERROR: Failed to write to log file: $LOG_FILE" >&2
            echo "$formatted_message" >&2
            return 1
        }
    else
        echo "$formatted_message" >&2
    fi

    return 0
}

# Convenience logging functions
log_debug() { log_message "$LOG_LEVEL_DEBUG" "DEBUG" "$1"; }
log_info()  { log_message "$LOG_LEVEL_INFO"  "INFO"  "$1"; }
log_warn()  { log_message "$LOG_LEVEL_WARN"  "WARN"  "$1"; }
log_error() { log_message "$LOG_LEVEL_ERROR" "ERROR" "$1"; }

# Initialize logging system
# shellcheck disable=SC2120
init_logging() {
    # Validate inputs
    if [[ -z "${LOG_LEVEL:-}" ]]; then
        echo "ERROR: LOG_LEVEL not set" >&2
        return 1
    fi
    if [[ -z "${LOG_FILE:-}" ]]; then
        echo "ERROR: LOG_FILE not set" >&2
        return 1
    fi
    if [[ -z "${LOG_FORMAT:-}" ]]; then
        echo "ERROR: LOG_FORMAT not set" >&2
        return 1
    fi

    # Validate log level
    if ! [[ "$LOG_LEVEL" =~ ^[0-3]$ ]]; then
        echo "ERROR: Invalid log level: $LOG_LEVEL" >&2
        return 1
    fi

    # Create logs directory
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
        echo "Creating log directory: $log_dir" >&2
        mkdir -p "$log_dir" || {
            echo "ERROR: Failed to create log directory: $log_dir" >&2
            return 1
        }
    fi

    # Ensure directory is writable
    if [[ ! -w "$log_dir" ]]; then
        echo "ERROR: Log directory not writable: $log_dir" >&2
        return 1
    fi

    # Truncate or create log file
    : > "$LOG_FILE" || {
        echo "ERROR: Cannot write to log file: $LOG_FILE" >&2
        return 1  
    }

    # Ensure file has correct permissions
    chmod 644 "$LOG_FILE" || {
        echo "ERROR: Cannot set permissions on log file: $LOG_FILE" >&2
        return 1
    }

    log_info "Logging initialized with level=$LOG_LEVEL"
    log_debug "Logging initialized with level=$LOG_LEVEL"
    return 0
}
