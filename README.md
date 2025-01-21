# RadioDJ Content Scheduling System

A comprehensive automation solution for radio content scheduling that seamlessly integrates with RadioDJ. This system manages everything from hour template creation to weekly scheduling, helping radio stations maintain consistent programming while optimizing content rotation and scheduling patterns.

## Overview

The RadioDJ Content Scheduling System provides end-to-end automation for radio programming, managing multiple rotation templates and their weekly scheduling. The system handles:
- Template Creation: Building hour-by-hour content structures
- Weekly Scheduling: Assigning templates to specific hours
- Pattern Balancing: Ensuring optimal distribution of content
- Event Integration: Automated loading via RadioDJ's event system
- Template Variety: Supporting 4, 6, 7, or 8 rotation patterns

### Key Features

#### Content Scheduling
- Multiple rotation template support (4/6/7/8 templates)
- Balanced template distribution
- Weekly schedule generation
- RadioDJ event architecture integration
- Automated schedule loading

#### Hour Building
- Automated template generation
- Configurable rotation rules
- Commercial break pattern management
- Category spacing enforcement
- Music selection optimization

#### System Integration
- Direct RadioDJ database connection
- Event-driven architecture
- Real-time schedule updates
- Performance monitoring
- Verification and validation tools

#### Database Management
- Table schema backups
- Single/Multi-table backup support
- Backup verification
- Sample data preservation

## RadioDJ Integration

This tool works directly with RadioDJ's database structure to:
- Read category definitions
- Access track information
- Generate compatible hour templates
- Maintain proper rotation patterns
- Export schedules in RadioDJ format

## Installation

### Prerequisites

#### System Requirements
- Bash 4.0 or higher
- Terminal with ANSI color support
- Standard GNU utilities
- jq (JSON processor)

#### Database Requirements
- MySQL 5.7 or newer
- Access to RadioDJ database
- CREATE, SELECT, UPDATE permissions
- Properly configured my.cnf or connection parameters

#### Optional Tools
- MySQL Workbench or similar for database inspection
- Screen or tmux for persistent sessions

### Setup Steps
1. Clone this repository:
```bash
git clone [repository-url]
```
2. Make scripts executable:
```bash
chmod +x *.sh
```
3. Configure database connection:
```bash
cp config.sample.sh config.sh
nano config.sh  # Edit your database settings
```

## Usage

Basic usage:
```bash
# Run the main scheduler
./radiodj-scheduler.sh

# Run backup tests
./tests/test-backup.sh

# Backup single table
./db-backup.sh events

# Backup multiple tables
./db-backup.sh "events songs rotations"
```

- `--no-debug`: Disable debug mode (enabled by default during testing)
- `-s, --show-current`: Display current hour template
- `-h, --help`: Show help message

Debug mode (default during testing):
- Shows detailed database operations
- Shows command execution details
- Sets logging level to DEBUG
- Shows SQL query results

Non-debug mode:
- Shows only essential information
- Sets logging level to INFO
- Cleaner status output

Log files are written to logs/app.log (excluded from git) with
format: [TIMESTAMP] [LEVEL] Message

Status indicators show operation progress:
- [.] Shows operation in progress
- [✓] Indicates success (in bold)
- [✗] Indicates failure (in bold)
show operation progress with [.], success [✓], or failure [✗].

Example:
```bash
./hour-builder.sh --debug
```

## Development Setup

1. Install development tools:
```bash
# For Ubuntu/Debian
sudo apt-get install shellcheck bats
```

2. Run tests:
```bash
bats tests/
```

3. Check script quality:
```bash
shellcheck *.sh
```

### Coding Standards

#### Function and File Naming
- Files: Use descriptive lowercase names with hyphens (e.g., `context-manager.sh`)
- Functions: Use snake_case for internal functions (e.g., `validate_input`)
- Public Functions: Use module_function_name format (e.g., `context_verify_relationship`)
- Test Files: Mirror implementation name with 'test-' prefix (e.g., `test-context-manager.sh`)
- Test Functions: Use test_ prefix (e.g., `test_verify_relationship`)

#### Database Naming
- Table Names: Use lowercase with underscores (e.g., `rotation_templates`)
- Column Names: Follow RadioDJ conventions (e.g., `ID`, `catID`, `subID`)
- Test Tables: Add '_test' suffix for test data (e.g., `categories_test`)

#### Code Organization
- Group related functions together
- Add descriptive comments for function blocks
- Use consistent indentation (4 spaces)
- Keep functions focused and single-purpose
- Follow shellcheck recommendations

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Run the test suite
5. Submit a pull request

## License

Copyright (c) 2023 Sky+Sea, LLC d/b/a KSStorm Media

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
