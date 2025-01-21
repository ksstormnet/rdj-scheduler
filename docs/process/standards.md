# Development Standards

## File Organization

1. Core Files
- Entry points in root directory
- Core libraries in src/lib/core
- Component loaders in src/lib/loaders
- Tests mirror src structure exactly
- Process documentation in docs/process

2. Directory Standards
- All scripts run from PROJECT_ROOT
- No relative path (..) navigation
- Use absolute paths from PROJECT_ROOT
- Mirror test and source structures

3. Naming Conventions
File Names:
- dash-separated-names.sh
- test-component-name.sh for tests
- Descriptive and purpose-indicating

Function Names:
- underscore_separated_names
- test_feature_name for test functions
- _internal_function for private functions
- Verb-first for actions (e.g., get_timestamp)

Variables:
- UPPERCASE for constants and exports
- lowercase_with_underscores for locals
- Descriptive and scope-appropriate

4. File Headers
```bash
#######################################
# Component Name
# Last Updated: [Date]
#
# Brief description of component purpose
# and primary responsibilities.
#
# Copyright 2025 Sky+Sea, LLC d/b/a KSStorm Media
# See LICENSE file for terms of use
#######################################
```

5. Function Documentation
```bash
#######################################
# Brief description of function purpose
# Arguments:
#   $1 - Description of first argument
#   $2 - Description of second argument
# Globals:
#   GLOBAL_VAR - Description if used
# Outputs:
#   Writes to stdout/stderr if applicable
# Returns:
#   0 on success, non-zero on error
#######################################
```

## Code Organization

1. Source Files
- Clear separation of concerns
- Single responsibility principle
- Proper dependency management
- Consistent initialization

2. Test Files
- One test file per component
- Tests grouped by functionality
- Clear setup and teardown
- Independent test cases

3. Documentation Location
- Implementation docs with code
- Process docs in docs/process/
- Feature docs in docs/features/
- README.md for project overview

## Display Architecture

1. Status Formatting
- Messages wrapped in brackets: [Message]
- Color applied to entire bracketed message
- Empty messages produce no output
- Status indicators:
    * [✓] success
    * [✗] failure
    * [.] progress

2. Color Standards
- RED: Errors and failures
- GREEN: Success and completion
- YELLOW: Warnings and progress
- BLUE: Information and status
- NC (No Color): Default text

3. Output Functions
- status_testing: Show operation in progress
- status_success: Indicate success
- status_failure: Indicate failure
- debug_write: Debug information

4. Implementation Requirements
- ANSI color support
- Single source of truth (display-helpers.sh)
- Consistent output format
- Proper stream handling (stdout/stderr)

## Logging Standards

1. Log Levels
- ERROR (0): Critical errors requiring immediate attention
- WARN (1): Important issues that aren't critical
- INFO (2): General operational information
- DEBUG (3): Detailed debugging information

2. Log Format
- ISO 8601 timestamps
- Consistent level labeling
- Clear, descriptive messages
- Proper level filtering

3. File Management
- Proper permissions (644)
- Directory creation as needed
- Clear initialization
- Resource cleanup

## Testing Standards

1. File Organization
- Mirror source directory structure
- test-[component].sh naming
- test_[feature] function naming
- Clear test grouping

2. Test Isolation
- Run in clean subshells
- Proper resource cleanup
- Independent test cases
- Clear setup/teardown

3. Assertion Standards
- Clear test descriptions
- One assertion per test
- Meaningful error messages
- Proper detail on failure

4. Test Output
- Status indicators for progress
- Clear success/failure marking
- Detailed error reporting
- Summary statistics
