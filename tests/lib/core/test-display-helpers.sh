#!/usr/bin/env bash
#######################################
# Display Helpers Test Suite
# Last Updated: 2025-01-21
#
# Test suite for core display functionality.
# Verifies color codes, symbols, and display functions.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Enable strict mode
set -euo pipefail
IFS=$'\n\t'

# Ensure PROJECT_ROOT is set
if [[ -z "${PROJECT_ROOT:-}" ]]; then
    echo "ERROR: PROJECT_ROOT must be set before running tests" >&2
    exit 1
fi

# Source the display helpers
if ! source "${PROJECT_ROOT}/src/lib/core/display-helpers.sh"; then
    echo "ERROR: Failed to source display-helpers.sh" >&2
    exit 1
fi

# Test Setup
setup_test() {
    OUTPUT_FILE=$(mktemp)
    ERROR_FILE=$(mktemp)
    echo "Created test files: ${OUTPUT_FILE} ${ERROR_FILE}"
}

teardown_test() {
    echo "Test output content:"
    cat "${OUTPUT_FILE}"
    echo "Test error content:"
    cat "${ERROR_FILE}"
    rm -f "${OUTPUT_FILE}" "${ERROR_FILE}"
}

# Test Cases
test_color_code_exports() {
    # Test color code definitions
    [[ -n "${COLOR_RED}" ]] || (echo "COLOR_RED not defined" && return 1)
    [[ -n "${COLOR_GREEN}" ]] || (echo "COLOR_GREEN not defined" && return 1)
    [[ -n "${COLOR_YELLOW}" ]] || (echo "COLOR_YELLOW not defined" && return 1)
    [[ -n "${COLOR_RESET}" ]] || (echo "COLOR_RESET not defined" && return 1)
    
    # Verify color codes are ANSI escape sequences
    [[ "${COLOR_RED}" == *$'\e['* ]] || (echo "COLOR_RED not ANSI escape sequence" && return 1)
    [[ "${COLOR_GREEN}" == *$'\e['* ]] || (echo "COLOR_GREEN not ANSI escape sequence" && return 1)
    [[ "${COLOR_YELLOW}" == *$'\e['* ]] || (echo "COLOR_YELLOW not ANSI escape sequence" && return 1)
    
    return 0
}

test_symbol_definitions() {
    # Test symbol definitions
    [[ -n "${SYMBOL_CHECK}" ]] || (echo "SYMBOL_CHECK not defined" && return 1)
    [[ -n "${SYMBOL_X}" ]] || (echo "SYMBOL_X not defined" && return 1)
    [[ -n "${SYMBOL_TESTING}" ]] || (echo "SYMBOL_TESTING not defined" && return 1)
    
    return 0
}

test_status_functions() {
    setup_test
    
    echo "Testing status_testing function..."
    status_testing "Test Message" > "${OUTPUT_FILE}"
    if ! grep -q "Test Message" "${OUTPUT_FILE}"; then
        echo "FAIL: status_testing output not found"
        echo "Output file content:"
        cat "${OUTPUT_FILE}"
        teardown_test
        return 1
    fi
    
    echo "Testing status_success function..."
    status_success "Success Message" > "${OUTPUT_FILE}"
    if ! grep -q "Success Message" "${OUTPUT_FILE}"; then
        echo "FAIL: status_success output not found"
        echo "Output file content:"
        cat "${OUTPUT_FILE}"
        teardown_test
        return 1
    fi
    
    echo "Testing status_failure function..."
    status_failure "Failure Message" > "${OUTPUT_FILE}"
    if ! grep -q "Failure Message" "${OUTPUT_FILE}"; then
        echo "FAIL: status_failure output not found"
        echo "Output file content:"
        cat "${OUTPUT_FILE}"
        teardown_test
        return 1
    fi
    
    teardown_test
    return 0
}

# Test runner
run_tests() {
    local test_functions=(
        "test_color_code_exports"
        "test_symbol_definitions"
        "test_status_functions"
    )
    
    local failures=0
    
    echo "Running display-helpers.sh tests..."
    for test_function in "${test_functions[@]}"; do
        echo -n "Running ${test_function}... "
        if ${test_function}; then
            echo "PASS"
        else
            echo "FAIL"
            ((failures++))
        fi
    done
    
    return ${failures}
}

# Run tests if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
