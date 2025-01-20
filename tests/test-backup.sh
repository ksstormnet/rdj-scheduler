#!/bin/bash
set -e

# Import logging functionality
. ./lib/logging.sh

# Set up test environment
export LOG_LEVEL=3  # LOG_LEVEL_DEBUG
export LOG_DIR="logs"
export LOG_FILE="${LOG_DIR}/test.log"
export BACKUP_DIR="backups"

# Create required directories
mkdir -p "$LOG_DIR" "$BACKUP_DIR"

# Initialize logging
if ! init_logging; then
    echo "Failed to initialize logging" >&2
    exit 1
fi

# Helper function for assertions
assert() {
    local message=$1
    local command=$2
    log_debug "Testing $message... "
    if eval "$command"; then
        log_info "PASS: $message"
        return 0
    else
        log_error "FAIL: $message"
        return 1
    fi
}

# Source the backup script
. ./db/db-backup.sh

# Clean existing log and backup files
rm -f "$BACKUP_DIR"/*

# Run backup for events table
log_info "Running backup test for events table..."
db_backup "events"

# Get today's date for filename checking
date_str=$(date +%Y-%m-%d)
backup_file="${BACKUP_DIR}/events-${date_str}.sql"

# Test assertions
assert "backup file exists" "[ -f \"${backup_file}\" ]"
assert "backup file is not empty" "[ -s \"${backup_file}\" ]"

# Test db_backup_schema_and_sample function
log_info "Running backup test for events table schema and sample..."
db_backup_schema_and_sample events

# Get today's date for schema sample backup filename checking
date_str=$(date +%Y-%m-%d)
schema_sample_file="${BACKUP_DIR}/events-schema-sample-${date_str}.sql"

# Test assertions for schema and sample backup
assert "schema sample backup file exists" "[ -f \"${schema_sample_file}\" ]"
assert "schema sample backup file is not empty" "[ -s \"${schema_sample_file}\" ]"

# Verify the backup contains CREATE TABLE statement but limited data
assert "backup contains schema" "grep -q 'CREATE TABLE' \"${schema_sample_file}\""
assert "backup has limited data" "! grep -q 'VALUES (.*),(.*' \"${schema_sample_file}\""

log_info "All tests completed successfully!"
log_info "You can examine the single table backup at: ${backup_file}"
log_info "You can examine the schema and sample backup at: ${schema_sample_file}"
