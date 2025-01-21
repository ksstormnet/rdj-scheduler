# Testing Standards and Framework

## Test Framework Architecture

1. Core Components
- test-framework.sh: Core testing infrastructure
  * Assertion functions
  * Environment management
  * Test grouping
  * Result reporting
- run-tests.sh: Test orchestration
  * Dependency-ordered execution
  * Subshell isolation
  * Automatic test discovery
  * Comprehensive reporting

2. Assertion Functions
```bash
# Basic condition testing
assert "Test name" "[ condition ]" "Optional detail"

# Value comparison
assert_equals "Compare values" "expected" "actual" "Detail"

# String containment
assert_contains "Find substring" "full string" "substring" "Detail"

# Pattern matching
assert_matches "Match pattern" "test string" "^pattern$" "Detail"
```

3. Test Organization
- Tests mirror source structure exactly
- One test file per component
- Tests grouped by functionality
- Independent test environments
- Dependency-ordered execution

4. Test Environment Management
```bash
# Initialize test environment
setup_test_environment "Test Suite Name"

# Group related tests
begin_test_group "Feature Group"

# Clean up after tests
cleanup_test_environment
```

## Test Implementation

1. Test File Structure
```bash
#!/usr/bin/env bash
#######################################
# [Component] Tests
# Last Updated: [Date]
#
# Test suite for [component description]
#######################################

cd "${PROJECT_ROOT}" || exit 1

test_specific_feature() {
    begin_test_group "Feature Name"
    
    assert "Description" "condition" "detail"
    assert_equals "Compare" "expected" "actual"
    assert_contains "Find" "haystack" "needle"
}

main() {
    setup_test_environment "Component Tests"
    test_specific_feature
    cleanup_test_environment
}

main
```

2. Real Implementation Example (logging.sh tests)
```bash
test_log_levels() {
    begin_test_group "Log Levels and Formatting"
    
    # Clear log file
    rm -f "$LOG_FILE"
    init_logging
    
    # Test debug logging
    log_debug "Test debug message"
    assert_contains "Debug logging" "$(cat "$LOG_FILE")" \
        "[DEBUG] Test debug message"
    
    # Test info logging
    log_info "Test info message"
    assert_contains "Info logging" "$(cat "$LOG_FILE")" \
        "[INFO] Test info message"
}
```

3. Test Isolation
Each test runs in its own subshell:
```bash
run_single_test() {
    local test_file="$1"
    # Run in subshell with fresh environment
    (
        export PROJECT_ROOT="$(pwd)"
        source "src/lib/core/display-helpers.sh"
        source "src/lib/core/logging.sh"
        source "src/lib/core/test-framework.sh"
        source "$test_file"
    )
}
```

4. Dependency-Ordered Execution
```bash
run_test_suite() {
    # Core modules first (order matters)
    run_single_test "tests/lib/core/test-display-helpers.sh"
    run_single_test "tests/lib/core/test-logging.sh"
    
    # Then additional tests
    while IFS= read -r -d '' file; do
        [[ "$file" =~ test-(display-helpers|logging)\.sh ]] && continue
        run_single_test "$file"
    done < <(find "tests" -type f -name "test-*.sh" -print0)
}
```

## Best Practices

1. Test Organization
- Group related tests logically
- Use descriptive test names
- One assertion per test case
- Clear setup and cleanup
- Meaningful failure messages

2. Resource Management
- Use setup_test_environment
- Clean up in cleanup_test_environment
- Create temporary files safely
- Handle errors gracefully
- Maintain test isolation

3. Test Categories
- Unit Tests: Individual function testing
- Integration Tests: Component interaction
- System Tests: End-to-end workflows
- Performance Tests: Load and timing

4. Coverage Requirements
- All public functions
- Error conditions
- Edge cases
- Performance requirements
- Resource cleanup

## Test Output and Reporting

1. Status Indicators
- [.] Test in progress
- [✓] Test passed
- [✗] Test failed

2. Failure Information
```
[✗] Test description
Expected: expected value
Actual: actual value
Detail: Additional context
```

3. Test Summary
```
Test Summary:
Total tests: N
Passed: X
Failed: Y
```
