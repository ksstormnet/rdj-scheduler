#!/bin/bash
#######################################
# Test Display Helper Functions
# Last Updated: 2025-01-21
#
# Tests for display helper functionality including
# status indicators, colors, and debug output.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Get script directory
declare -g SCRIPT_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the test framework
source "${SCRIPT_DIR}/../../test-framework.sh"

# Source the display helpers
source "${SCRIPT_DIR}/../../../src/lib/core/display-helpers.sh"

# Color Tests
test_color_exports() {
    local failed=0
    
    # Test each color code
    assert_not_empty "${COLOR_RED}" "RED color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_GREEN}" "GREEN color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_YELLOW}" "YELLOW color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_BLUE}" "BLUE color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_MAGENTA}" "MAGENTA color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_CYAN}" "CYAN color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_WHITE}" "WHITE color code should be exported" || ((failed++))
    assert_not_empty "${COLOR_RESET}" "RESET color code should be exported" || ((failed++))
    
    return $((failed > 0))
}

# Symbol Tests
test_symbol_exports() {
    local failed=0
    
    assert_equals "✓" "${SYMBOL_CHECK}" "CHECK symbol should be correct" || ((failed++))
    assert_equals "✗" "${SYMBOL_X}" "X symbol should be correct" || ((failed++))
    assert_equals "." "${SYMBOL_TESTING}" "TESTING symbol should be correct" || ((failed++))
    
    return $((failed > 0))
}

# Status Tests
test_status_testing() {
    local output
    output=$(status_testing "Testing message")
    
    assert_contains "${output}" "${SYMBOL_TESTING}" "Testing status should contain testing symbol" || return 1
    assert_contains "${output}" "Testing message" "Testing status should contain message" || return 1
    assert_not_empty "${COLOR_YELLOW}" "Testing status should use yellow color" || return 1
    return 0
}

test_status_success() {
    local output
    output=$(status_success "Success message")
    
    assert_contains "${output}" "${SYMBOL_CHECK}" "Success status should contain check symbol" || return 1
    assert_contains "${output}" "Success message" "Success status should contain message" || return 1
    assert_not_empty "${COLOR_GREEN}" "Success status should use green color" || return 1
    return 0
}

test_status_failure() {
    local output
    output=$(status_failure "Failure message")
    
    assert_contains "${output}" "${SYMBOL_X}" "Failure status should contain X symbol" || return 1
    assert_contains "${output}" "Failure message" "Failure status should contain message" || return 1
    assert_not_empty "${COLOR_RED}" "Failure status should use red color" || return 1
    return 0
}

# Debug Tests
test_debug_write_enabled() {
    local output
    is_debug=true
    output=$(debug_write "Debug message")
    
    assert_contains "${output}" "DEBUG:" "Debug output should contain DEBUG prefix" || return 1
    assert_contains "${output}" "Debug message" "Debug output should contain message" || return 1
    assert_not_empty "${COLOR_DIM_GREY}" "Debug output should use dim grey color" || return 1
    return 0
}

test_debug_write_disabled() {
    local output
    is_debug=false
    output=$(debug_write "Debug message")
    
    assert_empty "${output}" "Debug output should be empty when debug is disabled" || return 1
    return 0
}

# Main test runner
main() {
    run_test_suite \
        test_color_exports \
        test_symbol_exports \
        test_status_testing \
        test_status_success \
        test_status_failure \
        test_debug_write_enabled \
        test_debug_write_disabled
}

main "$@"
