#!/bin/bash
#######################################
# Test Framework
# Last Updated: 2025-01-21
#
# Core testing framework providing assertions
# and test running infrastructure for the 
# RadioDJ scheduler test suite.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

# Enable error tracing for debugging
set -x

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Test counters and state
TESTS_RUN=0
TESTS_FAILED=0
TESTS_PASSED=0
CURRENT_TEST=""
CURRENT_TEST_PASSED=0

# Test infrastructure
start_test() {
    CURRENT_TEST="$1"
    echo -e "\n${YELLOW}Running test: ${CURRENT_TEST}${NC}"
    ((TESTS_RUN++))
    CURRENT_TEST_PASSED=0  # Reset pass count for this test
}

test_success() {
    echo -e "${GREEN}✓ ${CURRENT_TEST}${NC}"
    ((CURRENT_TEST_PASSED++))
    return 0
}

test_failure() {
    local message="$1"
    echo -e "${RED}✗ ${CURRENT_TEST}: ${message}${NC}"
    ((TESTS_FAILED++))
    return 1
}

report_results() {
    echo "----------------------------------------"
    echo -e "Test Results:"
    echo -e "  Total:  ${TESTS_RUN}"
    echo -e "  ${GREEN}Passed: ${TESTS_PASSED}${NC}"
    if [ "${TESTS_FAILED}" -gt 0 ]; then
        echo -e "  ${RED}Failed: ${TESTS_FAILED}${NC}"
        return 1
    else
        echo -e "  Failed: ${TESTS_FAILED}"
        return 0
    fi
}

# Run a test with proper handling
run_test() {
    local test_function="$1"
    local test_failed=0
    
    start_test "${test_function}"
    
    # Run setup
    if declare -F setup >/dev/null; then
        if ! setup; then
            test_failure "Setup failed"
            return 1
        fi
    fi
    
    # Run test
    if ! ${test_function}; then
        test_failed=1
    else
        ((TESTS_PASSED++))
    fi
    
    # Run teardown
    if declare -F teardown >/dev/null; then
        if ! teardown; then
            test_failure "Teardown failed"
            return 1
        fi
    fi
    
    return ${test_failed}
}

# Assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected' but got '$actual'}"
    
    if [ "$expected" = "$actual" ]; then
        test_success
        return 0
    else
        test_failure "$message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected to find '$needle' in '$haystack'}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        test_success
        return 0
    else
        test_failure "$message"
        return 1
    fi
}

assert_empty() {
    local value="$1"
    local message="${2:-Expected empty string but got '$value'}"
    
    if [ -z "$value" ]; then
        test_success
        return 0
    else
        test_failure "$message"
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="${2:-Expected non-empty value but got empty string}"
    
    if [ -n "$value" ]; then
        test_success
        return 0
    else
        test_failure "$message"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-Expected file '$file' to exist}"
    
    if [ -f "$file" ]; then
        test_success
        return 0
    else
        test_failure "$message"
        return 1
    fi
}

# Run all provided tests
run_test_suite() {
    local failed=0
    
    # Run all tests
    for test_func in "$@"; do
        run_test "${test_func}" || ((failed++))
    done
    
    # Report results
    report_results
    return ${failed}
}
