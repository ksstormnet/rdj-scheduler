#!/bin/bash
#######################################
# Display Helper Functions
# Last Updated: 2025-01-21
#
# Helper functions for consistent terminal output
# formatting and status indicators.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# ANSI color codes for status messages and text
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[0;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_MAGENTA='\033[0;35m'
export COLOR_CYAN='\033[0;36m'
export COLOR_WHITE='\033[1;37m'
export COLOR_BOLD='\033[1m'
export COLOR_DIM_GREY='\033[1;30m'
export COLOR_RESET='\033[0m'

# Status indicator symbols
export SYMBOL_CHECK="✓"
export SYMBOL_X="✗"
export SYMBOL_TESTING="."

# Environment variables
declare -g is_debug=${is_debug:-false}

# Status indicator functions with proper spacing
status_testing() {
    local message="${1:-Testing...}"
    if [ "${is_debug}" = true ]; then
        printf "${COLOR_WHITE}${COLOR_BOLD}[${COLOR_YELLOW}${SYMBOL_TESTING}${COLOR_WHITE}]${COLOR_RESET} ${message}\n"
    else
        printf "${COLOR_WHITE}${COLOR_BOLD}[${COLOR_YELLOW}${SYMBOL_TESTING}${COLOR_WHITE}]${COLOR_RESET} ${message}"
    fi
}

status_success() {
    local message="${1:-Success}"
    if [ "${is_debug}" = true ]; then
        printf "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_GREEN}${SYMBOL_CHECK}${COLOR_WHITE}]${COLOR_RESET} ${message}\n\n"
    else
        printf "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_GREEN}${SYMBOL_CHECK}${COLOR_WHITE}]${COLOR_RESET} ${message}\n"
    fi
}

status_failure() {
    local message="${1:-Failed}"
    if [ "${is_debug}" = true ]; then
        printf "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_RED}${SYMBOL_X}${COLOR_WHITE}]${COLOR_RESET} ${message}\n\n"
    else
        printf "\r${COLOR_WHITE}${COLOR_BOLD}[${COLOR_RED}${SYMBOL_X}${COLOR_WHITE}]${COLOR_RESET} ${message}\n"
    fi
}

# Write debug message with consistent formatting
debug_write() {
    if [ "${is_debug}" = true ]; then
        printf "${COLOR_DIM_GREY}DEBUG: %s${COLOR_RESET}\n" "$1"
    fi
}

