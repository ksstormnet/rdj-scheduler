#!/usr/bin/env bash
#######################################
# Test Framework
# Last Updated: 2025-01-21
#
# Core test framework providing standardized assertions,
# test environment management, and result reporting.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Change to project root (required for consistent paths)
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)" || {
    echo "Error: Failed to change to project root directory" >&2
    exit 1
}

# Source required dependencies
source "src/lib/core/display-helpers.sh" || {
    echo "Error: Failed to load display-helpers.sh" >&2
    exit 1
}
source "src/lib/core/logging.sh" || {
    echo "Error: Failed to load logging.sh" >&2
    exit 1
}

# Test tracking variables
declare -g tests_total=0
declare -g tests_passed=0
declare -g tests_failed=0
declare -g current_test_group=""

#######################################
# Basic assertion with formatted output
# Arguments:
#   $1 - Test description
#   $2 - Command to evaluate
#   $3 - Optional additional details
# Returns:
#   0 if test passes, 1 if test fails
#######################################
assert() {
    local message="$1"
    local condition="$2"
    local detail="${3:-}"
    local error_output
    
    ((tests_total++))
    status_testing "$message"
    
    if error_output=$(eval "$condition" 2>&1); then
        status_success "$message"
        ((tests_passed++))
        return 0
    else
        status_failure "$message"
        if [[ -n "$detail" ]]; then
            echo -e "${COLOR_RED}Detail: ${detail}${COLOR_RESET}"
        fi
        echo -e "${COLOR_RED}Condition: ${condition}${COLOR_RESET}"
        echo -e "${COLOR_RED}Error output: ${error_output}${COLOR_RESET}"
        ((tests_failed++))
        return 1
    fi
}

#######################################
# Assert two values are equal
# Arguments:
#   $1 - Test description
#   $2 - Expected value
#   $3 - Actual value
#   $4 - Optional additional details
# Returns:
#   0 if values match, 1 if they differ
#######################################
assert_equals() {
    local message="$1"
    local expected="$2"
    local actual="$3"
    local detail="${4:-}"
    
    ((tests_total++))
    status_testing "$message"
    
    if [[ "$expected" == "$actual" ]]; then
        status_success "$message"
        ((tests_passed++))
        return 0
    else
        status_failure "$message"
        echo -e "${COLOR_RED}Expected: ${expected}${COLOR_RESET}"
        echo -e "${COLOR_RED}Actual: ${actual}${COLOR_RESET}"
        if [[ -n "$detail" ]]; then
            echo -e "${COLOR_RED}Detail: ${detail}${COLOR_RESET}"
        fi
        ((tests_failed++))
        return 1
    fi
}

#######################################
# Assert string contains substring
# Arguments:
#   $1 - Test description
#   $2 - String to search in
#   $3 - Substring to find
#   $4 - Optional additional details
# Returns:
#   0 if substring found, 1 if not found
#######################################
assert_contains() {
    local message="$1"
    local haystack="$2"
    local needle="$3"
    local detail="${4:-}"
    
    ((tests_total++))
    status_testing "$message"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        status_success "$message"
        ((tests_passed++))
        return 0
    else
        status_failure "$message"
        echo -e "${COLOR_RED}Expected to find: ${needle}${COLOR_RESET}"
        echo -e "${COLOR_RED}In string: ${haystack}${COLOR_RESET}"
        if [[ -n "$detail" ]]; then
            echo -e "${COLOR_RED}Detail: ${detail}${COLOR_RESET}"
        fi
        ((tests_failed++))
        return 1
    fi
}

#######################################
# Assert string matches regex pattern
# Arguments:
#   $1 - Test description
#   $2 - String to test
#   $3 - Regex pattern
#   $4 - Optional additional details
# Returns:
#   0 if pattern matches, 1 if no match
#######################################
assert_matches() {
    local message="$1"
    local test_string="$2"
    local pattern="$3"
    local detail="${4:-}"
    
    ((tests_total++))
    status_testing "$message"
    
    if [[ "$test_string" =~ $pattern ]]; then
        status_success "$message"
        ((tests_passed++))
        return 0
    else
        status_failure "$message"
        echo -e "${COLOR_RED}String: ${test_string}${COLOR_RESET}"
        echo -e "${COLOR_RED}Did not match pattern: ${pattern}${COLOR_RESET}"
        if [[ -n "$detail" ]]; then
            echo -e "${COLOR_RED}Detail: ${detail}${COLOR_RESET}"
        fi
        ((tests_failed++))
        return 1
    fi
}

#######################################
# Start a new test group
# Arguments:
#   $1 - Group name
# Outputs:
#   Group header to stdout
#######################################
begin_test_group() {
    current_test_group="$1"
    echo -e "\n${COLOR_BOLD}${COLOR_WHITE}Testing: ${current_test_group}${COLOR_RESET}"
    log_info "Starting test group: $current_test_group"
}

#######################################
# Set up clean test environment
# Arguments:
#   $1 - Optional test group name
# Returns:
#   0 if setup succeeds, 1 if fails
#######################################
setup_test_environment() {
    local group_name="${1:-}"
    
    # Reset test counters
    tests_total=0
    tests_passed=0
    tests_failed=0
    
    # Set up test group if provided
    if [[ -n "$group_name" ]]; then
        begin_test_group "$group_name"
    fi
    
    # Ensure we're in debug mode for maximum output
    export is_debug=true
    
    # Set up logging for tests
    export LOG_FILE="logs/test.log"
    export LOG_LEVEL="${LOG_LEVEL_DEBUG:-3}"
    
    # Create logs directory if needed
    mkdir -p "$(dirname "$LOG_FILE")" || {
        echo "Error: Failed to create logs directory" >&2
        return 1
    }
    
    # Clear previous log file
    : > "$LOG_FILE" || {
        echo "Error: Failed to clear log file" >&2
        return 1
    }
    
    log_info "Test environment initialized"
    return 0
}

#######################################
# Print test results summary
# Arguments:
#   None
# Outputs:
#   Test summary to stdout
#######################################
print_test_summary() {
    echo -e "\n${COLOR_WHITE}${COLOR_BOLD}Test Summary:${COLOR_RESET}"
    echo -e "Total tests: ${tests_total}"
    echo -e "${COLOR_GREEN}Passed: ${tests_passed}${COLOR_RESET}"
    
    if [[ ${tests_failed} -gt 0 ]]; then
        echo -e "${COLOR_RED}Failed: ${tests_failed}${COLOR_RESET}"
    fi
    
    if [[ -n "$current_test_group" ]]; then
        log_info "Completed test group: $current_test_group"
        log_info "Results: ${tests_passed}/${tests_total} tests passed"
    fi
}

#######################################
# Clean up test environment
# Arguments:
#   None
# Returns:
#   0 if cleanup succeeds, 1 if fails
#######################################
cleanup_test_environment() {
    # Print final summary
    print_test_summary
    
    # Reset test group
    current_test_group=""
    
    # Return success if all tests passed
    [[ ${tests_failed} -eq 0 ]]
}
