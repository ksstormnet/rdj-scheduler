#!/usr/bin/env bash
#######################################
# Logging Module Tests
# Last Updated: 2025-01-21
#
# Test suite for the logging module. Validates log level
# filtering, message formatting, and initialization.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Get absolute path of script location and change to project root
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)" || {
    echo "Error: Failed to change to project root directory" >&2
    exit 1
}

# Source display helpers (required)
source "src/lib/core/display-helpers.sh" || {
    echo "Error: Failed to load display-helpers.sh" >&2
    exit 1
}

# Test tracking variables
tests_total=0
tests_passed=0
tests_failed=0

#######################################
# Assert test condition with formatted output
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
# Set up test environment
# Arguments:
#   None
# Returns:
#   0 if setup succeeds, 1 if fails
#######################################
setup_test_environment() {
    status_testing "Setting up test environment"
    
    # Create logs directory
    mkdir -p "logs" || {
        status_failure "Failed to create logs directory"
        return 1
    }
    
    # Configure logging
    export LOG_FILE="logs/test.log"
    export LOG_LEVEL="${LOG_LEVEL_DEBUG:-3}"
    
    # Remove existing log file
    rm -f "$LOG_FILE"
    
    status_success "Test environment setup complete"
    debug_write " - Log file: $LOG_FILE"
    debug_write " - Log level: $LOG_LEVEL"
}

#######################################
# Test logging initialization
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_initialization() {
    status_testing "Testing logging initialization"
    source "src/lib/core/logging.sh"
    init_logging
    assert "Log file created" "[ -f '$LOG_FILE' ]" "Log file creation failed"
}

#######################################
# Test log levels and formatting
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_log_levels() {
    status_testing "Testing log levels"
    
    assert "Debug logging" "log_debug 'Test debug message' && grep -q '\[DEBUG\] Test debug message' '$LOG_FILE'"
    assert "Info logging" "log_info 'Test info message' && grep -q '\[INFO\] Test info message' '$LOG_FILE'"
    assert "Warning logging" "log_warn 'Test warning message' && grep -q '\[WARN\] Test warning message' '$LOG_FILE'"
    assert "Error logging" "log_error 'Test error message' && grep -q '\[ERROR\] Test error message' '$LOG_FILE'"
}

#######################################
# Test log level filtering
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_log_filtering() {
    status_testing "Testing log level filtering"
    
    # Clear log file
    rm -f "$LOG_FILE"
    
    # Set to INFO level
    export LOG_LEVEL="${LOG_LEVEL_INFO:-2}"
    init_logging
    
    log_debug "Should not appear in log"
    log_info "Should appear in log"
    
    assert "Debug messages filtered" "! grep -q 'Should not appear' '$LOG_FILE'"
    assert "Info messages logged" "grep -q 'Should appear' '$LOG_FILE'"
}

#######################################
# Print test summary
# Arguments:
#   None
# Outputs:
#   Test summary to stdout
#######################################
print_summary() {
    echo
    echo -e "${COLOR_WHITE}${COLOR_BOLD}Test Summary:${COLOR_RESET}"
    echo -e "Total tests: ${tests_total}"
    echo -e "${COLOR_GREEN}Passed: ${tests_passed}${COLOR_RESET}"
    
    if [[ ${tests_failed} -gt 0 ]]; then
        echo -e "${COLOR_RED}Failed: ${tests_failed}${COLOR_RESET}"
    fi
}

#######################################
# Main test execution
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
main() {
    # Disable error exit for tests
    set +e
    
    setup_test_environment
    test_initialization
    test_log_levels
    test_log_filtering
    print_summary
    
    # Exit with failure if any tests failed
    [[ ${tests_failed} -eq 0 ]]
}

main
