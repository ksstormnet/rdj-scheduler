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

# Change to project root
cd "${PROJECT_ROOT}" || {
    echo "Error: Failed to change to project root directory" >&2
    exit 1
}

#######################################
# Test logging initialization
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_initialization() {
    begin_test_group "Logging Initialization"
    
    # Clear any existing log file
    rm -f "$LOG_FILE"
    
    # Test initialization
    assert "Logging initialization" "init_logging" "Failed to initialize logging"
    
    # Immediately check log file existence and emptiness
    assert "Log file created" "[ -f '$LOG_FILE' ]" "Log file creation failed"
    assert_equals "Log file initially empty" "0" "$(wc -l < "$LOG_FILE")" "Log file should be empty after initialization"
    
    # Test permissions after we've verified existence
    assert_matches "Log file permissions" "$(stat -c %a "$LOG_FILE")" "^[6][0-9][0-9]$" "Log file permissions should be user writable"
    
    # Now we can start logging for other tests
    log_debug "Initialization tests complete"
}

#######################################
# Test log levels and formatting
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_log_levels() {
    begin_test_group "Log Levels and Formatting"
    
    # Clear log file before testing
    rm -f "$LOG_FILE"
    init_logging
    
    # Test debug logging
    log_debug "Test debug message"
    assert_contains "Debug logging" "$(cat "$LOG_FILE")" "[DEBUG] Test debug message"
    
    # Test info logging
    log_info "Test info message"
    assert_contains "Info logging" "$(cat "$LOG_FILE")" "[INFO] Test info message"
    
    # Test warning logging
    log_warn "Test warning message"
    assert_contains "Warning logging" "$(cat "$LOG_FILE")" "[WARN] Test warning message"
    
    # Test error logging
    log_error "Test error message"
    assert_contains "Error logging" "$(cat "$LOG_FILE")" "[ERROR] Test error message"
    
    # Test timestamp format
    assert_matches "Timestamp format" "$(head -n1 "$LOG_FILE")" "^\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z\]"
}

#######################################
# Test log level filtering
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_log_filtering() {
    begin_test_group "Log Level Filtering"
    
    # Clear log file and reinitialize
    rm -f "$LOG_FILE"
    export LOG_LEVEL="$LOG_LEVEL_INFO"
    init_logging
    
    # Test debug messages are filtered
    log_debug "Should not appear in log"
    assert "Debug messages filtered" "! grep -q 'Should not appear' '$LOG_FILE'"
    
    # Test info messages appear
    log_info "Should appear in log"
    assert_contains "Info messages logged" "$(cat "$LOG_FILE")" "Should appear in log"
    
    # Test error always appears regardless of level
    log_error "Error message"
    assert_contains "Error messages always logged" "$(cat "$LOG_FILE")" "Error message"
}

#######################################
# Main test execution
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
main() {
    setup_test_environment "Logging Module Tests" || exit 1
    
    test_initialization
    test_log_levels
    test_log_filtering
    
    cleanup_test_environment
}

main
