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

## RadioDJ Integration

This tool works directly with RadioDJ's database structure to:
- Read category definitions
- Access track information
- Generate compatible hour templates
- Maintain proper rotation patterns
- Export schedules in RadioDJ format

## Installation

### Prerequisites
- Bash 4.0 or higher
- Access to RadioDJ database
- SQLite3 command-line tools
- jq (JSON processor)
- Standard GNU utilities

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
./hour-builder.sh
```

Available options:
- `-d, --debug`: Enable debug mode for detailed output
- `-s, --show-current`: Display current hour template
- `-h, --help`: Show help message

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

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Run the test suite
5. Submit a pull request

## License

Copyright (c) 2023 Sky+Sea, LLC d/b/a KSStorm Media

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
