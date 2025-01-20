#!/bin/bash

is_debug=true
if [[ "$1" == "--no-debug" ]]; then
    is_debug=false
fi

# Source display helpers 
. display-helpers.sh
trap cleanup EXIT

# Test status progression
# Database status progression
status_testing "Database connectivity check"
debug_write "Attempting connection to MySQL server..."
sleep 0.5
debug_write "Verifying credentials..."
sleep 0.5
status_success "Database connectivity check"

# Table validation with failure
status_testing "Verifying database tables" 
debug_write "Checking tablespace allocation..."
sleep 0.5
debug_write "Found inconsistency in table structure"
sleep 0.5
debug_write "Error: Invalid index on primary key"
sleep 0.5
status_failure "Verifying database tables"

# Data integrity check with debugging
status_testing "Data integrity verification"
debug_write "Scanning record checksums..."
sleep 0.5
debug_write "Verifying relational constraints..."
sleep 0.5
debug_write "Found 842 valid records"
sleep 0.5
status_success "Data integrity verification"

# Multi-step process test
status_testing "Backup verification"
debug_write "Checking backup timestamps..."
sleep 0.5
debug_write "Validating backup contents..."
ls /nonexistent 2>/dev/null  # Force some stderr output
sleep 0.5
status_failure "Backup verification"

# Multi-phase test 
for phase in "Schema validation" "Index verification" "Record counting" "Transaction logs" "User permissions"; do
    status_testing "$phase"
    debug_write "Running $phase checks..."
    sleep 0.5
    if [[ "$phase" == "Index verification" || "$phase" == "Transaction logs" ]]; then
        debug_write "Found issues in $phase"
        status_failure "$phase"
    else
        debug_write "Completed $phase successfully"
        status_success "$phase"
    fi
done
