# Project Structure

## Directory Organization
```
radiodj/
├── run-app.sh          # Main application entry point
├── run-tests.sh        # Test suite entry point
├── src/                # Source code
│   ├── lib/            # Core libraries
│   │   ├── core/       # Core functionality
│   │   │   ├── display-helpers.sh  # Display functions (loaded first)
│   │   │   ├── logging.sh          # Logging functionality
│   │   │   └── test-framework.sh   # Testing infrastructure
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
│   ├── process/        # Development process docs
│   │   ├── overview.md      # Project overview
│   │   ├── structure.md     # This file
│   │   ├── standards.md     # Development standards
│   │   ├── testing.md       # Test framework docs
│   │   ├── components.md    # Implementation status
│   │   └── documentation.md # Doc standards
│   ├── db/             # Database documentation
│   ├── features/       # Feature-specific docs
│   └── scheduling/     # Scheduling rules
├── config/             # Configuration files
└── backups/            # Backup files (git-ignored)
```

## Path Management
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
2. logging.sh (Core logging)
3. Other component loaders
4. Application logic

Test Path:
1. display-helpers.sh (First, authoritative)
2. logging.sh (Core logging)
3. test-framework.sh (Test infrastructure)
4. Individual tests (in dependency order)
```

### Entry Point Standards

1. Application Entry (run-app.sh)
```bash
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# Load display helpers first
source "src/lib/core/display-helpers.sh"

# Load logging system
source "src/lib/core/logging.sh"

# Then other components
source "src/lib/loaders/core-loader.sh"
```

2. Test Entry (run-tests.sh)
```bash
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

# Load core dependencies for main script
source "src/lib/core/display-helpers.sh"
source "src/lib/core/logging.sh"
source "src/lib/core/test-framework.sh"

# Execute tests in isolated subshells
run_single_test() {
    local test_file="$1"
    
    # Run test in subshell with fresh environment
    (
        export PROJECT_ROOT="$(pwd)"
        source "src/lib/core/display-helpers.sh"
        source "src/lib/core/logging.sh"
        source "src/lib/core/test-framework.sh"
        source "$test_file"
    )
}

# Run tests in dependency order
run_test_suite() {
    # Core modules first (order matters)
    run_single_test "tests/lib/core/test-display-helpers.sh"
    run_single_test "tests/lib/core/test-logging.sh"
    
    # Then discover and run remaining tests
    find "tests" -type f -name "test-*.sh"
}
```

### Dependency Management

1. Core Module Dependencies
```
display-helpers.sh  <-- logging.sh
                      ^
                      |
                  test-framework.sh
```

2. Test Isolation
- Each test runs in its own subshell
- Fresh environment for each test
- Dependencies reloaded per test
- No cross-test contamination

3. Test Order Enforcement
- Core modules tested first
- display-helpers.sh tests run first
- logging.sh tests run second
- Additional tests discovered and run after core tests

4. Environment Management
- PROJECT_ROOT set by entry points
- Each test changes to PROJECT_ROOT
- Clean environment per test
- Proper cleanup after each test
