#!/usr/bin/env bash
#######################################
# RadioDJ Scheduler Test Suite Runner
# Last Updated: 2025-01-21
#
# Test suite runner for the RadioDJ scheduler application.
# Executes unit tests and integration tests, providing coverage reports.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

set -euo pipefail
IFS=$'\n\t'

# Get the absolute path to the project root
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source display helpers (required)
if ! source "${PROJECT_ROOT}/src/lib/core/display-helpers.sh"; then
    echo "Error: Failed to load display-helpers.sh" >&2
    exit 1
fi

# Source logging module (required)
if ! source "${PROJECT_ROOT}/src/lib/core/logging.sh"; then
    echo "Error: Failed to load logging.sh" >&2
    exit 1
fi

# Set test environment
export is_debug=true

# Run a single test file
run_single_test() {
    local test_file="$1"
    status_testing "Running ${test_file#"${PROJECT_ROOT}/"}"
    if bash "$test_file"; then
        status_success "✓ ${test_file#"${PROJECT_ROOT}/"}"
        return 0
    else
        status_failure "✗ ${test_file#"${PROJECT_ROOT}/"}"
        return 1
    fi
}

# Run all test files
run_test_suite() {
    local test_files=()
    local failures=0
    
    # Run core module tests in specific order to respect dependencies
    status_testing "Running core module tests in order"
    
    # 1. Display helpers tests (must run first as other modules depend on it)
    if ! run_single_test "${PROJECT_ROOT}/tests/lib/core/test-display-helpers.sh"; then
        ((failures++))
    fi
    
    # 2. Logging tests (depends on display helpers)
    if ! run_single_test "${PROJECT_ROOT}/tests/lib/core/test-logging.sh"; then
        ((failures++))
    fi
    
    # Discover and run remaining tests
    status_testing "Running additional tests"
    while IFS= read -r -d '' file; do
        # Skip core module tests as they were already run
        if [[ "$file" =~ test-(display-helpers|logging)\.sh ]]; then
            continue
        fi
        test_files+=("$file")
    done < <(find "${PROJECT_ROOT}/tests" -type f -name "test-*.sh" -print0)
    
    status_testing "Found ${#test_files[@]} additional test files"
    # Run discovered tests
    for test_file in "${test_files[@]}"; do
        if ! run_single_test "$test_file"; then
            ((failures++))
        fi
    done
            ((failures++))
        fi
    done
    
    if [ "$failures" -eq 0 ]; then
        status_success "All tests passed"
    else
        status_failure "${failures} test files failed"
        return 1
    fi
}

# Main test execution
run_test_suite
