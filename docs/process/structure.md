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
4. Individual tests
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

# Load core dependencies
source "src/lib/core/display-helpers.sh"
source "src/lib/core/logging.sh"
source "src/lib/core/test-framework.sh"
```
