#!/bin/bash
#
# Copyright (c) 2023 Sky+Sea LLC d/b/a KSStorm Media
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -euo pipefail
IFS=$'\n\t'

# Test framework variables
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Set up script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source the logging library
if ! source "${SCRIPT_DIR}/lib/logging.sh"; then
    echo "Failed to source logging library"
    exit 1
fi

# Configure logging
export LOG_FILE="logs/test.log"
export LOG_LEVEL="${LOG_LEVEL_DEBUG}"

# Test helper function
assert() {
    local message="$1"
    local condition="$2"
    local detail="${3:-}"
    local error_output
    
    ((TESTS_TOTAL++))

    if error_output=$(eval "$condition" 2>&1); then
        echo -e "${GREEN}✓ PASS${NC}: ${message}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: ${message}"
        if [[ -n "${detail}" ]]; then
            echo -e "${RED}     Detail: ${detail}${NC}"
        fi
        echo -e "${RED}     Condition: ${condition}${NC}"
        echo -e "${RED}     Error output: ${error_output}${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup() {
    echo -e "\nSetting up test environment..."
    # Create logs directory
    mkdir -p "$(dirname "${LOG_FILE}")"
    # Remove existing log
    rm -f "${LOG_FILE}" 
    # Debug output
    echo "Test setup:"
    echo " - Script dir: ${SCRIPT_DIR}"
    echo " - Log file: ${LOG_FILE}"
    echo " - Log level: ${LOG_LEVEL}"
}

# Test initialization
test_init() {
    echo -e "\nTesting initialization..."
    init_logging
    # Debug output
    echo " - Checking log file..."
    ls -l "${LOG_FILE}" || true
    assert "Log file created" "[ -f '${LOG_FILE}' ]" "Log file creation failed"
}

# Test log levels and formatting
test_log_levels() {
    echo -e "\nTesting log levels..."
    
    echo "  - Testing DEBUG level"
    log_debug "Test debug message"
    assert "Debug message logged" "grep -q '\\[DEBUG\\] Test debug message' '${LOG_FILE}'"
    
    echo "  - Testing INFO level"
    log_info "Test info message"
    assert "Info message logged" "grep -q '\\[INFO\\] Test info message' '${LOG_FILE}'"
    
    echo "  - Testing WARN level"
    log_warn "Test warning message"
    assert "Warning message logged" "grep -q '\\[WARN\\] Test warning message' '${LOG_FILE}'"
    
    echo "  - Testing ERROR level"
    log_error "Test error message"
    assert "Error message logged" "grep -q '\\[ERROR\\] Test error message' '${LOG_FILE}'"
}

# Test log level filtering
# Test log level filtering
test_log_filtering() {
    echo -e "\nTesting log level filtering..."
    
    # Clear log file before filtering test
    rm -f "${LOG_FILE}"
    
    # Set to INFO level to filter DEBUG messages
    export LOG_LEVEL="${LOG_LEVEL_INFO}"
    init_logging
    
    echo " - Current log level: ${LOG_LEVEL}"
    
    # Test filtering
    log_debug "Should not appear in log"
    log_info "Should appear in log"
    
    # Debug output to verify log file
    echo " - Checking log contents..."
    [ -f "${LOG_FILE}" ] && cat "${LOG_FILE}"
    
    assert "Debug messages are filtered" "! grep -q 'Should not appear' '${LOG_FILE}'"
    assert "Info messages are logged" "grep -q 'Should appear' '${LOG_FILE}'"
}

# Print test summary
print_summary() {
    echo -e "\n${YELLOW}Test Summary:${NC}"
    echo "Total tests: ${TESTS_TOTAL}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
    
    if [[ ${TESTS_FAILED} -gt 0 ]]; then
        echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    fi
}

# Main test execution
main() {
    # Disable error exit for tests
    set +e
    
    setup
    test_init
    test_log_levels
    test_log_filtering
    print_summary
    
    # Exit with failure if any tests failed
    [[ ${TESTS_FAILED} -eq 0 ]]
}

main
