# Radio Scheduler Development Process

## Directory Structure

```
radiodj/
├── scripts/              # Main script directory
│   ├── core/            # Core functionality scripts
│   ├── utils/           # Utility scripts
│   └── db/              # Database interaction scripts
├── tests/               # BATS test files
│   ├── unit/           # Unit tests
│   └── integration/    # Integration tests
├── config/              # Configuration files
│   ├── templates/      # Hour templates
│   └── rules/         # Business rules
└── docs/               # Documentation
```

## Component Breakdown

### Core Components
1. Database Interaction Layer
- db-connect.sh: Database connection management
- db-query.sh: Common query operations
- db-update.sh: Database update operations

2. Template Management
- template-parser.sh: Parse hour templates
- template-validator.sh: Validate template structure
- template-builder.sh: Generate new templates

3. Content Scheduling
- slot-finder.sh: Find available slots
- content-matcher.sh: Match content to slots
- rotation-manager.sh: Manage content rotation

4. Business Rules Engine
- rule-validator.sh: Validate against rules
- constraint-checker.sh: Check scheduling constraints
- pattern-matcher.sh: Verify commercial patterns

5. Main Scheduler
- hour-builder.sh: Main scheduling script
- schedule-generator.sh: Generate full schedules
- export-schedule.sh: Export to RadioDJ format

## Testing Strategy

### Unit Testing
- Use BATS (Bash Automated Testing System)
- One test file per script
- Test structure:
```bash
@test "function_name: test description" {
    run ./script_name.sh args
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "expected output" ]
}
```

### Integration Testing
- Test component interactions
- Use mock database for testing
- Verify end-to-end workflows
- Test business rule compliance

## Implementation Phases

### Phase 1: Foundation (2 weeks)
1. Set up project structure
2. Implement basic database connectivity
3. Create configuration management
4. Establish test framework

### Phase 2: Core Components (3 weeks)
1. Implement template management
2. Develop basic content matching
3. Create slot finding logic
4. Build rotation management

### Phase 3: Business Rules (2 weeks)
1. Implement rule validation
2. Add constraint checking
3. Create pattern matching
4. Develop position rules

### Phase 4: Integration (2 weeks)
1. Combine components
2. Implement main scheduler
3. Add export functionality
4. Create logging and error handling

### Phase 5: Testing and Refinement (1 week)
1. Comprehensive testing
2. Performance optimization
3. Documentation
4. Bug fixing

## Display Architecture

### Terminal Output Standards
1. Status Message Format
- [.] Shows operation in progress
- [✓] Indicates success
- [✗] Indicates failure
- Status messages are white by default
- Use single-line updates in non-debug mode

2. Debug Output
- Prefixed with "DEBUG:" in dim grey
- Only shown when debug mode is enabled
- Output through stderr
- Provides detailed operation information
- Includes timing and verification data

3. Color Standards
- Status messages: White
- Success indicators: Green
- Failure indicators: Red
- Debug messages: Dim grey
- Error messages: Red

### Terminal Requirements
1. Display Compatibility
- ANSI color support required
- Unicode support for status indicators
- Minimum 80x24 terminal size
- Support for carriage return (\r)

2. Testing Considerations
- Test both debug and non-debug modes
- Verify color display in various terminals
- Check status line overwriting
- Validate debug output formatting

### Component Status Output
1. Development Standards
- Use status_testing() for operations in progress
- Use status_success() for successful completion
- Use status_failure() for operation failures
- Include meaningful status messages
- Keep status updates concise

2. Integration Requirements
- Consistent status format across components
- Clear error reporting
- Proper debug output handling
- Status message spacing standardization

### Debug Output Conventions
1. Message Format
- Begin with component/function name
- Include relevant variable values
- Show operation progression
- Keep messages clear and concise

2. Output Categories
- Operation progress
- Variable state changes
- Error conditions
- Performance metrics
- Database operations

## Integration Approach

1. Component Integration
- Start with utility functions
- Add database layer
- Integrate business rules
- Combine scheduling components

2. Testing Strategy
- Unit test each component
- Integration tests for combined features
- End-to-end testing of workflows

3. Database Integration
- Start with SQLite for testing
- Add RadioDJ database support
- Implement failover handling

## Development Workflow

1. Test-Driven Development
```bash
# 1. Write test
vim tests/unit/test_script.bats
# 2. Run test (should fail)
bats tests/unit/test_script.bats
# 3. Implement feature
vim scripts/script.sh
# 4. Run test (should pass)
bats tests/unit/test_script.bats
# 5. Refactor if needed
```

2. Git Workflow
- One feature branch per component
- Pull request for each completed component
- Code review required
- Tests must pass before merge

3. Commit Strategy
- Atomic commits
- Clear commit messages
- Reference ticket numbers
- Include test cases

4. Documentation
- Update docs with each feature
- Include usage examples
- Document configuration options
- Maintain CHANGELOG.md

## Quality Assurance

1. Code Quality
- Use shellcheck for linting
- Follow Google's Shell Style Guide
- Regular code reviews
- Maintain modular design

2. Testing Requirements
- 100% test coverage for critical paths
- Both positive and negative test cases
- Performance benchmarks
- Security testing

3. Monitoring
- Error logging
- Performance metrics
- Usage statistics
- Database monitoring

## Delivery and Deployment

1. Release Process
- Version tagging
- CHANGELOG updates
- Documentation updates
- Backup procedures

2. Installation
- Installation script
- Dependency checking
- Configuration validation
- Database setup

3. Maintenance
- Regular updates
- Security patches
- Performance optimization
- Bug fixes

