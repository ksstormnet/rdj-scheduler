#!/usr/bin/env bash
#######################################
# Display Helpers Tests
# Last Updated: 2025-01-21
#
# Test suite for the display helper functions. Validates
# color codes, symbols, and status display functions.
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
# Test color code exports and formatting
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_color_code_exports() {
    begin_test_group "Color Code Exports"

    # Test color code definitions
    assert "COLOR_RED defined" "[[ -n '${COLOR_RED}' ]]" "COLOR_RED should be defined"
    assert "COLOR_GREEN defined" "[[ -n '${COLOR_GREEN}' ]]" "COLOR_GREEN should be defined"
    assert "COLOR_YELLOW defined" "[[ -n '${COLOR_YELLOW}' ]]" "COLOR_YELLOW should be defined"
    assert "COLOR_RESET defined" "[[ -n '${COLOR_RESET}' ]]" "COLOR_RESET should be defined"

    # Verify color codes are ANSI escape sequences
    assert_contains "COLOR_RED is ANSI" "${COLOR_RED}" $'\e[' "COLOR_RED should be ANSI escape sequence"
    assert_contains "COLOR_GREEN is ANSI" "${COLOR_GREEN}" $'\e[' "COLOR_GREEN should be ANSI escape sequence"
    assert_contains "COLOR_YELLOW is ANSI" "${COLOR_YELLOW}" $'\e[' "COLOR_YELLOW should be ANSI escape sequence"
}

#######################################
# Test display symbol definitions
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_symbol_definitions() {
    begin_test_group "Display Symbols"

    assert "SYMBOL_CHECK defined" "[[ -n '${SYMBOL_CHECK}' ]]" "SYMBOL_CHECK should be defined"
    assert "SYMBOL_X defined" "[[ -n '${SYMBOL_X}' ]]" "SYMBOL_X should be defined"
    assert "SYMBOL_TESTING defined" "[[ -n '${SYMBOL_TESTING}' ]]" "SYMBOL_TESTING should be defined"

    # Verify symbol contents
    assert_matches "SYMBOL_CHECK format" "${SYMBOL_CHECK}" "^[✓]$" "SYMBOL_CHECK should be check mark"
    assert_matches "SYMBOL_X format" "${SYMBOL_X}" "^[✗]$" "SYMBOL_X should be X mark"
    assert_matches "SYMBOL_TESTING format" "${SYMBOL_TESTING}" "^[.]$" "SYMBOL_TESTING should be dot"
}

#######################################
# Test status display functions
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
test_status_functions() {
    begin_test_group "Status Functions"

    # Create temporary files for output capture
    local output_file error_file
    output_file=$(mktemp)
    error_file=$(mktemp)
    debug_write "Created test files: ${output_file} ${error_file}"

    # Test status_testing function
    status_testing "Test Message" > "${output_file}"
    assert_contains "status_testing output" "$(cat "${output_file}")" "Test Message"
    assert_contains "status_testing symbol" "$(cat "${output_file}")" "${SYMBOL_TESTING}"

    # Test status_success function
    status_success "Success Message" > "${output_file}"
    assert_contains "status_success output" "$(cat "${output_file}")" "Success Message"
    assert_contains "status_success symbol" "$(cat "${output_file}")" "${SYMBOL_CHECK}"

    # Test status_failure function
    status_failure "Failure Message" > "${output_file}"
    assert_contains "status_failure output" "$(cat "${output_file}")" "Failure Message"
    assert_contains "status_failure symbol" "$(cat "${output_file}")" "${SYMBOL_X}"

    # Clean up test files
    rm -f "${output_file}" "${error_file}"
}

#######################################
# Main test execution
# Arguments:
#   None
# Returns:
#   0 if all tests pass, 1 if any fail
#######################################
main() {
    setup_test_environment "Display Helpers Tests" || exit 1

    test_color_code_exports
    test_symbol_definitions
    test_status_functions

    cleanup_test_environment
}

main
