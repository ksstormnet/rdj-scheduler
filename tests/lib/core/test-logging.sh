#######################################
# Test Logging Functions
# Last Updated: 2024-01-16
#
# Tests for the core logging functionality including debug,
# info, warning and error message handling.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Get script directory
declare -g SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the test framework
source "${SCRIPT_DIR}/../../test-framework.sh"

# Source the logging functions
source "${SCRIPT_DIR}/../../../src/lib/core/logging.sh"

# Test variables
declare -g TEST_LOG_FILE
TEST_LOG_FILE="/tmp/test-logging.$$.log"

############################
# Setup and Teardown
############################

setup() {
    # Ensure we can create our test log file
    if ! touch "${TEST_LOG_FILE}" 2>/dev/null; then
        echo "ERROR: Cannot create test log file: ${TEST_LOG_FILE}" >&2
        echo "Please ensure you have write permissions to the directory" >&2
        return 1
    fi
    
    # Reset log file content
    true > "${TEST_LOG_FILE}"
    
    # Ensure the file has proper permissions
    chmod 644 "${TEST_LOG_FILE}"
}

teardown() {
    rm -f "${TEST_LOG_FILE}"
}

############################
# Debug Message Tests
############################

test_debug_disabled() {
    local msg="Debug message test"
    local result
    
    # Set debug to disabled
    DEBUG=0
    
    # Run debug command
    debug "${msg}"
    
    # Check log file content - should be empty
    result="$(cat "${TEST_LOG_FILE}")"
    assert_empty "${result}" "Debug message should not appear when debug is disabled"
}

test_debug_enabled() {
    local msg="Debug message test"
    local result
    
    DEBUG=1
    debug "${msg}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[DEBUG] ${msg}" "Debug message should appear when debug is enabled"
}

############################
# Info Message Tests 
############################

test_info_message() {
    local msg="Info message test"
    local result
    
    info "${msg}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[INFO] ${msg}" "Info message should be logged correctly"
}

test_info_multiple_messages() {
    local msg1="First info message"
    local msg2="Second info message"
    local result
    
    info "${msg1}"
    info "${msg2}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[INFO] ${msg1}" "First info message should be logged"
    assert_contains "${result}" "[INFO] ${msg2}" "Second info message should be logged"
}

############################
# Warning Message Tests
############################

test_warning_message() {
    local msg="Warning message test"
    local result
    
    warning "${msg}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[WARNING] ${msg}" "Warning message should be logged correctly"
}

test_warning_multiple_messages() {
    local msg1="First warning message"
    local msg2="Second warning message"
    local result
    
    warning "${msg1}"
    warning "${msg2}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[WARNING] ${msg1}" "First warning message should be logged"
    assert_contains "${result}" "[WARNING] ${msg2}" "Second warning message should be logged"
}

############################
# Error Message Tests
############################

test_error_message() {
    local msg="Error message test"
    local result
    
    error "${msg}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[ERROR] ${msg}" "Error message should be logged correctly"
}

test_error_multiple_messages() {
    local msg1="First error message"
    local msg2="Second error message"
    local result
    
    error "${msg1}"
    error "${msg2}"
    result="$(cat "${TEST_LOG_FILE}")"
    
    assert_contains "${result}" "[ERROR] ${msg1}" "First error message should be logged"
    assert_contains "${result}" "[ERROR] ${msg2}" "Second error message should be logged"
}

############################
# Log File Tests
############################

test_log_file_creation() {
    assert_file_exists "${TEST_LOG_FILE}" "Log file should be created"
}

test_log_file_permissions() {
    local perms
    perms="$(stat -c %a "${TEST_LOG_FILE}")"
    
    assert_equals "644" "${perms}" "Log file should have correct permissions"
}

############################
# Main Test Runner
############################

main() {
    local failed=0
    
    run_test test_debug_disabled || failed=1
    run_test test_debug_enabled || failed=1
    run_test test_info_message || failed=1
    run_test test_info_multiple_messages || failed=1
    run_test test_warning_message || failed=1
    run_test test_warning_multiple_messages || failed=1
    run_test test_error_message || failed=1
    run_test test_error_multiple_messages || failed=1
    run_test test_log_file_creation || failed=1
    run_test test_log_file_permissions || failed=1
    
    return ${failed}
}

main "$@"

