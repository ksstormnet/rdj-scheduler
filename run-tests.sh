#!/usr/bin/env bash
#######################################
# RadioDJ Scheduler Test Suite Runner
# Last Updated: 2025-01-21
#
# Test suite runner for the RadioDJ scheduler application.
# Executes unit tests and integration tests in dependency order.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################

set -euo pipefail
IFS=$'\n\t'

# Get the absolute path to the project root
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || {
    echo "Error: Failed to change to project root directory" >&2
    exit 1
}

# Run a single test file in a subshell with framework loaded
run_single_test() {
    local test_file="$1"
    status_testing "Running ${test_file#"$(pwd)/"}"
    
    # Run test file in a subshell with all dependencies sourced
    if (
        export PROJECT_ROOT="$(pwd)"
        source "src/lib/core/display-helpers.sh" &&
        source "src/lib/core/logging.sh" &&
        source "src/lib/core/test-framework.sh" &&
        source "$test_file"
    ); then
        status_success "✓ ${test_file#"$(pwd)/"}"
        return 0
    else
        status_failure "✗ ${test_file#"$(pwd)/"}"
        return 1
    fi
}

# Source dependencies for the main script
source "src/lib/core/display-helpers.sh" || {
    echo "Error: Failed to load display-helpers.sh" >&2
    exit 1
}

source "src/lib/core/logging.sh" || {
    echo "Error: Failed to load logging.sh" >&2
    exit 1
}

source "src/lib/core/test-framework.sh" || {
    echo "Error: Failed to load test-framework.sh" >&2
    exit 1
}

# Run all test files
run_test_suite() {
    local test_files=()
    local failures=0

    # Initialize test environment
    setup_test_environment "RadioDJ Test Suite" || {
        status_failure "Failed to initialize test environment"
        return 1
    }
    
    # Run core module tests in specific order to respect dependencies
    begin_test_group "Core Module Tests"
    
    # 1. Display helpers tests (must run first as other modules depend on it)
    if ! run_single_test "tests/lib/core/test-display-helpers.sh"; then
        ((failures++))
    fi
    
    # 2. Logging tests (depends on display helpers)
    if ! run_single_test "tests/lib/core/test-logging.sh"; then
        ((failures++))
    fi
    
    # Discover and run remaining tests
    begin_test_group "Additional Tests"
    
    # Find additional test files
    while IFS= read -r -d '' file; do
        # Skip core module tests as they were already run
        if [[ "$file" =~ test-(display-helpers|logging)\.sh ]]; then
            continue
        fi
        test_files+=("$file")
    done < <(find "tests" -type f -name "test-*.sh" -print0)
    
    status_testing "Found ${#test_files[@]} additional test files"
    
    # Run discovered tests
    for test_file in "${test_files[@]}"; do
        if ! run_single_test "$test_file"; then
            ((failures++))
        fi
    done

    # Clean up and report results
    cleanup_test_environment
    
    if [ "$failures" -eq 0 ]; then
        status_success "All test suites passed"
        return 0
    else
        status_failure "$failures test suites failed"
        return 1
    fi
}

# Main execution
run_test_suite
