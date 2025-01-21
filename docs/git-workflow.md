# Git Workflow Standards

## Commit Message Format

All commits must follow the structured format defined in the commit template:

```
<type>(<scope>): <subject>
|<----  Using a maximum of 50 characters  ---->|

<body: Why this change was made and what it does>
|<----   Try to limit each line to a maximum of 72 characters   ---->|
```

### Type Categories
- feat: new feature
- fix: bug fix
- refactor: code refactoring
- style: formatting changes
- docs: documentation changes
- test: test additions/updates
- chore: maintenance tasks
- perf: performance improvements
- ci: continuous integration
- build: build system changes
- revert: reverting changes

### Scope Guidelines
- Scope should indicate the area of change
- Examples: db, templates, docs, structure, tests
- Use consistent scope names across commits
- Optional but recommended

### Subject Line Rules
- Use imperative mood (e.g., "add" not "added")
- Don't capitalize first letter
- No period at end
- Maximum 50 characters

### Commit Body Guidelines
- Explain what and why vs. how
- Use imperative mood
- Include context and motivation
- Reference issues and documentation
- Separate paragraphs with blank lines

## Branch Naming Conventions

Branches should follow the format: `<type>/<description>`

Types:
- feature/: new features
- bugfix/: bug fixes
- hotfix/: urgent fixes
- task/: general tasks
- refactor/: code refactoring
- docs/: documentation updates

Description should be brief but descriptive, using hyphens for spaces.

Examples:
- feature/template-generation
- bugfix/db-connection-timeout
- task/refactor-backup-system

## File Organization Standards

### Source Code Structure
```
src/
├── templates/     # Template system code
├── db/           # Database operations
└── lib/          # Shared libraries
```

### Documentation Structure
```
docs/
├── process.md               # Overall development process
├── git-workflow.md          # Git standards and processes
├── db/                      # Database documentation
├── features/                # Feature-specific documentation
│   └── templates/           # Template system docs
└── scheduling/              # Scheduling rules
```

### Support Directories
```
test/        # Test files
config/      # Configuration
backups/     # Backup files (git-ignored)
```

## Git-ignored Directories and Files

### Runtime and Temporary Files
- backups/: Backup files and directories
- .work/: Temporary work files
- tmp/: Temporary files
- logs/: Log files
- *.log: All log files
- *.tmp: Temporary files
- *.pid: Process ID files
- *.sock: Socket files

### Environment and Configuration
- .env: Environment files
- *.local.conf: Local configuration
- config.local: Local settings

### Development Tools
- .vscode/: VS Code settings (except specific files)
- .zed/: Zed editor files
- *.swp: Vim swap files
- *~: Backup files

## Best Practices

### Directory Management
- Use .gitkeep for empty directories that should be tracked
- Organize files by function and purpose
- Maintain consistent naming conventions
- Keep related files together

### Safety Practices
- Always verify git status before commits
- Keep runtime data out of version control
- Use appropriate .gitignore patterns
- Verify file moves and reorganizations
- Create backups before major changes

### Code Review Guidelines
- Review commit messages for clarity
- Verify appropriate file organization
- Check for sensitive data exposure
- Validate documentation updates
- Ensure commit atomicity
