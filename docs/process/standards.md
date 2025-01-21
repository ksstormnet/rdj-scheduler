# Development Standards

## File Organization

1. Core Files
- Entry points in root directory
- Core libraries in src/lib/core
- Component loaders in src/lib/loaders
- Tests mirror src structure

2. Naming Conventions
- Files: dash-separated-names.sh
- Functions: underscore_separated_names
- Test files: test-component-name.sh
- Variables: UPPERCASE for constants, lowercase for locals

3. File Headers
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

## Display Architecture

1. Status Formatting
- Messages wrapped in brackets: [Message]
- Color applied to entire bracketed message
- Empty messages produce no output
- Status indicators: [✓] success, [✗] failure, [.] progress

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
