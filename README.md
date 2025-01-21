# RadioDJ Content Scheduling System

A comprehensive automation solution for radio content scheduling that seamlessly integrates with RadioDJ. This system manages everything from hour template creation to weekly scheduling, helping radio stations maintain consistent programming while optimizing content rotation and scheduling patterns.

## Overview

The RadioDJ Content Scheduling System provides end-to-end automation for radio programming, managing multiple rotation templates and their weekly scheduling. The system handles:
- Template Creation: Building hour-by-hour content structures
- Weekly Scheduling: Assigning templates to specific hours
- Pattern Balancing: Ensuring optimal distribution of content
- Event Integration: Automated loading via RadioDJ's event system
- Template Variety: Supporting 4, 6, 7, or 8 rotation patterns

## Quick Start

### Prerequisites
- Bash 4.0 or higher
- Terminal with ANSI color support
- MySQL 5.7 or newer
- RadioDJ database access

### Installation
```bash
# Clone repository
git clone [repository-url]

# Make scripts executable
chmod +x run-app.sh run-tests.sh

# Run tests
./run-tests.sh
```

## Development

### Project Structure
```
radiodj/
├── run-app.sh            # Application entry point
├── run-tests.sh          # Test suite entry point
├── src/                  # Source code
│   └── lib/              # Core libraries
├── tests/                # Test files
└── docs/                 # Documentation
    └── process/          # Development process
```

### Documentation
Comprehensive documentation is available in docs/process/:

- [Project Overview](docs/process/overview.md)
- [Project Structure](docs/process/structure.md)
- [Development Standards](docs/process/standards.md)
- [Testing Framework](docs/process/testing.md)
- [Component Status](docs/process/components.md)
- [Documentation Guide](docs/process/documentation.md)

## Contributing

1. Review the documentation in docs/process/
2. Follow our development standards
3. Ensure tests pass with ./run-tests.sh
4. Submit pull request

## License

Copyright (c) 2025 Sky+Sea, LLC d/b/a KSStorm Media

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
