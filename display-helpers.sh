#!/bin/bash

# ANSI color codes for status messages and text
export COLOR_RED=$'\e[0;31m'
export COLOR_GREEN=$'\e[0;32m'
export COLOR_YELLOW=$'\e[0;33m'
export COLOR_BLUE=$'\e[0;34m'
export COLOR_MAGENTA=$'\e[0;35m'
export COLOR_CYAN=$'\e[0;36m'
export COLOR_WHITE=$'\e[1;37m'
export COLOR_DIM_GREY=$'\e[1;30m'
export COLOR_RESET=$'\e[0m'

# Status indicator symbols
export SYMBOL_CHECK="✓"
export SYMBOL_X="✗"
export SYMBOL_TESTING="."

# Status indicator functions with proper spacing
status_testing() { 
    if [ "$is_debug" = true ]; then
        echo -en "${COLOR_YELLOW}[${SYMBOL_TESTING}]${COLOR_RESET} ${COLOR_WHITE}$1${COLOR_RESET}\n"
    else
        echo -en "${COLOR_YELLOW}[${SYMBOL_TESTING}]${COLOR_RESET} ${COLOR_WHITE}$1${COLOR_RESET}"
    fi
    sleep 1
}

status_success() {
    if [ "$is_debug" = true ]; then
        echo -en "${COLOR_GREEN}[${SYMBOL_CHECK}]${COLOR_RESET} ${COLOR_WHITE}$1${COLOR_RESET}\n\n"
    else
        echo -en "\r${COLOR_GREEN}[${SYMBOL_CHECK}]${COLOR_RESET} ${COLOR_WHITE}$1${COLOR_RESET}\n"
    fi
}

status_failure() {
    if [ "$is_debug" = true ]; then
        echo -en "${COLOR_RED}[${SYMBOL_X}]${COLOR_RESET} ${COLOR_WHITE}$1${COLOR_RESET}\n\n"
    else
        echo -en "\r${COLOR_RED}[${SYMBOL_X}]${COLOR_RESET} ${COLOR_WHITE}$1${COLOR_RESET}\n"
    fi
}

# Write debug message with consistent formatting
debug_write() {
    if [ "$is_debug" = true ]; then
        echo -e "${COLOR_DIM_GREY}DEBUG: $1${COLOR_RESET}"
    fi
}

# Redirect stderr to debug output with consistent formatting
if [ -t 2 ] && [ "$is_debug" = true ]; then
    exec 2> >(while read -r line; do debug_write "$line"; done)
fi

# Reset colors on exit
cleanup() {
    if [ -t 1 ]; then
        echo -en "${COLOR_RESET}"
    fi
}
trap cleanup EXIT
