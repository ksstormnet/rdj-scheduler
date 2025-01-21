#!/usr/bin/env bash
#######################################
# Display Helpers
# Last Updated: 2025-01-21
#
# Core display functionality for consistent UI/UX across the application.
# Provides color codes, symbols, and standardized status display functions.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Enable strict mode
set -euo pipefail

# Allow for non-constant source and local declaration warning suppressions
# shellcheck disable=SC1090,SC2155

#######################################
# ANSI Color Code Definitions
#######################################
export COLOR_RED=$'\e[0;31m'
export COLOR_GREEN=$'\e[0;32m'
export COLOR_YELLOW=$'\e[0;33m'
export COLOR_BLUE=$'\e[0;34m'
export COLOR_MAGENTA=$'\e[0;35m'
export COLOR_CYAN=$'\e[0;36m'
export COLOR_WHITE=$'\e[1;37m'
export COLOR_BOLD=$'\e[1m'
export COLOR_DIM_GREY=$'\e[1;30m'
export COLOR_RESET=$'\e[0m'

#######################################
# Status Symbol Definitions
#######################################
export SYMBOL_CHECK="✓"
export SYMBOL_X="✗"
export SYMBOL_TESTING="."

#######################################
# Display Functions
#######################################

# Display a status message during test/operation execution
# Args:
#   $1 - Optional message text (defaults to "Testing...")
# Outputs:
#   Writes status message to stdout with proper formatting
status_testing() {
    local message="${1:-}"
    if [ -z "$message" ]; then
        message="Testing..."
    fi
    if [ "${is_debug:-false}" = true ]; then
        echo -en "${COLOR_WHITE}${COLOR_BOLD}[${COLOR_YELLOW}${SYMBOL_TESTING}${COLOR_WHITE}]${COLOR_RESET} ${message}\n"
    else
        echo -en "${COLOR_WHITE}${COLOR_BOLD}[${COLOR_YELLOW}${SYMBOL_TESTING}${COLOR_WHITE}]${COLOR_RESET} ${message}"
    fi
    sleep 1
}

# Display a success message after operation completion
# Args:
#   $1 - Optional success message (defaults to "Success")
# Outputs:
#   Writes success message to stdout with proper formatting
status_success() {
    local message="${1:-}"
    if [ -z "$message" ]; then
        message="Success"
    fi
    if [ "${is_debug:-false}" = true ]; then
        echo -en "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_GREEN}${SYMBOL_CHECK}${COLOR_WHITE}]${COLOR_RESET} ${message}\n\n"
    else
        echo -en "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_GREEN}${SYMBOL_CHECK}${COLOR_WHITE}]${COLOR_RESET} ${message}\n"
    fi
}

# Display a failure message after operation failure
# Args:
#   $1 - Optional failure message (defaults to "Failed")
# Outputs:
#   Writes failure message to stdout with proper formatting
status_failure() {
    local message="${1:-}"
    if [ -z "$message" ]; then
        message="Failed"
    fi
    if [ "${is_debug:-false}" = true ]; then
        echo -en "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_RED}${SYMBOL_X}${COLOR_WHITE}]${COLOR_RESET} ${message}\n\n"
    else
        echo -en "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_RED}${SYMBOL_X}${COLOR_WHITE}]${COLOR_RESET} ${message}\n"
    fi
}

#######################################
# Debug Output Functions
#######################################

# Write a debug message with consistent formatting
# Args:
#   $1 - Debug message to display
# Outputs:
#   Writes debug message to stdout if debug mode is enabled
debug_write() {
    if [ "${is_debug:-false}" = true ]; then
        echo -e "${COLOR_DIM_GREY}DEBUG: $1${COLOR_RESET}"
    fi
}

# Configure debug output redirection
if [ -t 2 ] && [ "${is_debug:-false}" = true ]; then
    exec 2> >(while read -r line; do debug_write "$line"; done)
fi

#######################################
# Cleanup Functions
#######################################

# Reset colors on script exit
# No Args
# No Outputs (terminal reset only)
cleanup() {
    if [ -t 1 ]; then
        echo -en "${COLOR_RESET}"
    fi
}
trap cleanup EXIT

