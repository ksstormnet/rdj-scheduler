#!/bin/bash

# Copyright (c) 2024 Sky+Sea LLC d/b/a KSStorm Media
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# RadioDJ Scheduler - Linux service script for scheduling RadioDJ events

# Enable bash safety settings
set -euo pipefail

# Version information
VERSION="1.0.0"

# Script directory setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup script configuration
# Debug mode and logging configuration
# TODO: Change is_debug default to false before final release
# Load logging lib early so we can use its constants
# shellcheck source=lib/logging.sh
source "${SCRIPT_DIR}/lib/logging.sh"

# Configure logging
LOG_DIR="logs"
export LOG_FILE="${LOG_DIR}/app.log"

# Create logs directory if it doesn't exist 
mkdir -p "$LOG_DIR"

# Debug mode enabled by default during testing
# TODO: Change is_debug default to false before final release
export is_debug=true

# Set initial log level based on debug mode
# DEBUG (3) if debug mode is on, INFO (2) otherwise
export LOG_LEVEL=$([[ "$is_debug" = true ]] && echo "$LOG_LEVEL_DEBUG" || echo "$LOG_LEVEL_INFO")

# Load helper functions
# shellcheck source=lib/display-helpers.sh
source "${SCRIPT_DIR}/lib/display-helpers.sh"

# Function to show help/usage information
show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -d, --debug          Enable debug mode (sets log level to DEBUG)"
    echo "                       Note: Currently enabled by default for testing"
    echo "  --no-debug           Disable debug mode, use INFO level"
    echo "  --log-level LEVEL    Set log level (ERROR=0, WARN=1, INFO=2, DEBUG=3)"
    echo "                       Default: DEBUG in debug mode, INFO otherwise"
    echo
    exit 0
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -d|--debug)
            is_debug=true
            export LOG_LEVEL="$LOG_LEVEL_DEBUG"
            shift
            ;;
        --no-debug)
            is_debug=false
            export LOG_LEVEL="$LOG_LEVEL_INFO"
            shift
            ;;
        --log-level)
            if [ -n "${2:-}" ]; then
                if [[ "$2" =~ ^[0-3]$ ]]; then
                    LOG_LEVEL="$2"
                    shift 2
                else
                    echo "Error: Invalid log level. Must be 0-3 (ERROR=0, WARN=1, INFO=2, DEBUG=3)"
                    exit 1
                fi
            else
                echo "Error: --log-level requires a level argument"
                exit 1
            fi
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_help
            ;;
    esac
done

# Initialize logging system
init_logging "$LOG_FILE" "$LOG_LEVEL" || {
    echo "Error: Failed to initialize logging system"
    exit 1
}

# Log startup information
log_info "RadioDJ Scheduler v$VERSION starting up..."
log_debug "Initialized with log level $LOG_LEVEL"

# Load database interface functions
# shellcheck source=db/db-interface.sh
source "${SCRIPT_DIR}/db/db-interface.sh"
# shellcheck source=db/db-test.sh
source "${SCRIPT_DIR}/db/db-test.sh"

# Main function definition
main() {
    # Test database connection first
    log_info "Testing database connection..."
    if ! test_database_connection; then
        log_error "Database connection test failed"
        return 1
    fi
    log_info "Database connection test successful"
    
    # Test songs table access
    log_info "Testing songs table access..."
    if ! test_songs_table; then
        log_error "Songs table access test failed"
        return 1
    fi
    log_info "Songs table access test successful"
    
    return 0
}

# Function to clean up resources and perform any final logging before exit
# shellcheck disable=SC2317  # Ignore unreachable code warning for trap
cleanup() {
    local exit_code=$?
    log_info "Cleaning up resources..."

    # Log appropriate shutdown message based on exit code
    if [ "$exit_code" -eq 0 ]; then
        log_info "RadioDJ Scheduler completed successfully"
    else
        log_error "RadioDJ Scheduler failed with exit code $exit_code"
    fi

    return "$exit_code"
}

# Set up trap to ensure proper cleanup on exit
trap cleanup EXIT INT TERM

# Execute main function and exit with its status
if main; then
    log_info "RadioDJ Scheduler execution completed successfully"
    exit 0
else
    log_error "RadioDJ Scheduler execution failed"
    exit 1
fi
