# Radio Scheduler Development Process

## Overview

This document outlines the development process, standards, and architecture for the RadioDJ 
scheduler project. It serves as the authoritative source for project structure and development practices.

## Project Structure

### Directory Organization
```
radiodj/
├── run-app.sh          # Main application entry point
├── run-tests.sh        # Test suite entry point
├── src/                # Source code
│   ├── lib/            # Core libraries
│   │   ├── core/       # Core functionality
│   │   │   ├── display-helpers.sh  # Display functions (loaded first)
│   │   │   └── logging.sh          # Logging functionality
│   │   └── loaders/    # Component loaders
│   │       ├── core-loader.sh      # Core component loader
│   │       └── test-loader.sh      # Test environment loader
│   ├── db/             # Database operations
│   └── scheduling/     # Scheduling logic
├── tests/              # Test files
│   ├── lib/            # Mirrors src/lib structure
│   │   └── core/       # Core component tests
│   └── db/             # Database tests
├── docs/               # Documentation
│   ├── db/             # Database documentation
│   ├── features/       # Feature-specific docs
│   └── scheduling/     # Scheduling rules
├── config/             # Configuration files
└── backups/            # Backup files (git-ignored)
```

### Path Management
- All operations run from project root
- No relative path (..) navigation
- Paths referenced from PROJECT_ROOT
- Consistent path resolution across components

## Load Order and Dependencies

### Core Principles

1. Display Functions (Primary)
- display-helpers.sh loads first
- Single source of truth for display functions
- No redefinition in other components
- Required by both app and test paths

2. Project Root Based
- All scripts run from project root
- Fixed, predictable file locations
- PROJECT_ROOT set in entry points
- Consistent working directory

3. Component Loading Sequence
```
Application Path:
1. display-helpers.sh (First, authoritative)
2. core-loader.sh (Core functionality)
3. Other component loaders
4. Application logic

Test Path:
1. display-helpers.sh (First, authoritative)
2. test-framework.sh (Test infrastructure)
3. test-loader.sh (Test environment)
4. Individual tests
```

### Entry Point Standards

1. Application Entry (run-app.sh)
```bash
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# Load display helpers first
source "src/lib/core/display-helpers.sh"

# Then other components
source "src/lib/loaders/core-loader.sh"
```

2. Test Entry (run-tests.sh)
```bash
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# Load display helpers first
source "src/lib/core/display-helpers.sh"

# Then test framework
source "tests/test-framework.sh"
```

## Development Standards

### File Organization
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

### Display Architecture

1. Status Formatting
- Messages wrapped in brackets: [Message]
- Color applied to entire bracketed message
- Empty messages produce no output
- Status indicators: [✓] success, [✗] failure

2. Color Standards
- RED: Errors and failures
- GREEN: Success and completion
- YELLOW: Warnings and progress
- BLUE: Information and status
- NC (No Color): Default text

3. Output Functions
- display_status: Primary status output
- display_message: Plain text output
- display_error: Error messages (to stderr)
- display_warning: Warning messages
- display_info: Informational messages

4. Implementation Requirements
- ANSI color support
- Single source of truth (display-helpers.sh)
- Consistent output format
- Proper stream handling (stdout/stderr)

### Testing Standards

1. Test Organization
- Tests mirror source structure
- One test file per component
- Independent test environments
- Consistent test naming

2. Test Implementation
- Test real implementations
- Clear separation of test/production code
- Independent test cases
- Proper setup/teardown

3. Test Environment
- Isolated test directories
- Clean environment for each test
- Proper resource cleanup
- Mock minimal necessary components

## Component Implementation

### Core Components

1. Display System (Implemented)
- display-helpers.sh: Core display functionality
    * Color definitions
    * Status display
    * Message formatting
    * First-loaded component

2. Test Framework (Implemented)
- test-framework.sh: Testing infrastructure
    * Assertions
    * Test execution
    * Result reporting
    * Uses display-helpers.sh

3. Component Loaders (In Progress)
- Manage dependency loading
- Handle initialization
- Prevent multiple loading
- Export shared functions

4. Database Layer (Planned)
- Database connectivity
- Transaction management
- Query execution
- Error handling

5. Scheduling System (Planned)
- Template management
- Schedule generation
- Rule enforcement
- Content rotation

## Implementation Phases

### Phase 1: Core Infrastructure (Current)
1. ✓ Project structure
2. ✓ Display system
3. ✓ Test framework
4. Component loaders
5. Base utilities

### Phase 2: Database Layer (Next)
1. Connection management
2. Query interface
3. Transaction handling
4. Error recovery

### Phase 3: Scheduling Core
1. Template system
2. Rule engine
3. Content management
4. Schedule generation

### Phase 4: Integration
1. RadioDJ connectivity
2. External APIs
3. Backup system
4. Monitoring

### Phase 5: Refinement
1. Performance optimization
2. Error handling
3. Documentation
4. Deployment

## Testing Strategy

### Test Categories

1. Unit Tests
- Individual component testing
- Function-level verification
- Isolated environments
- Mock external dependencies

2. Integration Tests
- Component interaction testing
- Subsystem verification
- Database integration
- Error handling

3. System Tests
- End-to-end workflows
- Performance testing
- Error recovery
- Load testing

### Test Implementation

1. Test Structure
- Mirror source structure
- Consistent naming
- Clear documentation
- Independent execution

2. Test Environment
- Clean setup/teardown
- Resource isolation
- Error trapping
- State verification

3. Test Coverage
- All public functions
- Error conditions
- Edge cases
- Performance requirements

## Documentation Standards

### Code Documentation
1. File Headers
- Component description
- Last update date
- Copyright notice
- Usage notes

2. Function Documentation
- Purpose description
- Parameter details
- Return values
- Error conditions

3. Implementation Notes
- Algorithm descriptions
- Dependency requirements
- Usage examples
- Known limitations

### Project Documentation
1. README.md
- Project overview
- Setup instructions
- Usage examples
- Development setup

2. Process Documentation
- Development standards
- Architecture details
- Implementation phases
- Testing strategy

3. Feature Documentation
- Functional requirements
- Implementation details
- Testing requirements
- Usage guidelines
