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

# Enable bash safety settings
set -euo pipefail

# Default to debug mode in development
is_debug=true

# Function to show help/usage information
show_help() {
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -d, --debug    Enable debug mode (default: on in development)"
    echo "  --no-debug     Disable debug mode"
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
            shift
            ;;
        --no-debug)
            is_debug=false
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Generic command executor with error handling
# Generic command executor with error handling
event_run() {
    local event_status
    local output
    
    # Execute command and capture both stdout and stderr
    output=$("$@" 2>&1)
    event_status=$?
    
    # Handle any errors
    if [[ $event_status -ne 0 ]] && $is_debug; then
        debug_write "Command failed, exit code $event_status"
    fi
    
    # Return output for caller to handle  
    echo "$output"
    return $event_status
}

# Script directory for sourcing components
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source additional components

# Source additional components
# shellcheck disable=SC1094
source "${SCRIPT_DIR}/display-helpers.sh"
source "${SCRIPT_DIR}/db/db-interface.sh"
source "${SCRIPT_DIR}/db/db-test.sh"
# Main function definition
main() {
    # Test database connection first
    if ! test_database_connection; then
        return 1
    fi
    
    # Test songs table access
    if ! test_songs_table; then
        return 1
    fi
}

# Call main function
main
exit $?
