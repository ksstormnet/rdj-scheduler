#!/bin/bash

# Copyright (c) 2024 Sky+Sea LLC d/b/a KSStorm Media
# MIT License - See LICENSE file for details

# Enable bash safety settings
set -euo pipefail

# This script handles all database operations for the RadioDJ scheduler
# It provides functions for querying and manipulating the RadioDJ database

# Begin a database transaction
# Returns: 0 on success, 1 on failure
db_begin() {
    debug_write "Starting transaction..."
    if ! event_run mysql radiodj -e "START TRANSACTION;"; then
        return 1
    fi
    return 0
}

# Commit the current transaction
# Returns: 0 on success, 1 on failure
db_commit() {
    debug_write "Committing transaction..."
    if ! event_run mysql radiodj -e "COMMIT;"; then
        return 1
    fi
    return 0
}

# Rollback the current transaction
# Returns: 0 on success, 1 on failure
db_rollback() {
    debug_write "Rolling back transaction..."
    if ! event_run mysql radiodj -e "ROLLBACK;"; then
        return 1
    fi
    return 0
}

# Execute a SELECT query
# $1: query string
# Returns: query result on success, 1 on failure
db_select() {
    local query="$1"
    debug_write "Executing SELECT query..."
    local result
    if ! result=$(event_run mysql radiodj -N -B -e "$query"); then
        return 1
    fi
    echo "$result"
    return 0
}

# Execute an UPDATE/INSERT/DELETE query
# $1: query string
# Returns: 0 on success, 1 on failure
db_execute() {
    local query="$1"
    debug_write "Executing SQL query..."
    if ! event_run mysql radiodj -e "$query"; then
        return 1
    fi
    return 0
}

# Test database connection and access
# Returns: 0 on success, non-zero on failure
test_database_connection() {
    status_testing "DB Connection"
    
    # Check for ~/.my.cnf configuration
    if [[ ! -f "${HOME}/.my.cnf" ]]; then
        status_failure "DB Connection (${HOME}/.my.cnf not found)"
        return 1
    fi

    # Test basic MySQL connection
    debug_write "Testing MySQL connection..."
    if ! event_run mysql -e "SELECT 1;" >/dev/null 2>&1; then
        status_failure "DB Connection (connection failed)"
        return 2
    fi

    # Test RadioDJ database access
    debug_write "Testing RadioDJ database access..."
    if ! event_run mysql -e "USE radiodj; SELECT 1;" >/dev/null 2>&1; then
        status_failure "DB Connection (radiodj database not accessible)"
        return 3
    fi

    status_success "DB Connection"
    return 0
}

# Test if the songs table is accessible
# Returns: 0 on success, non-zero on failure
test_songs_table() {
    status_testing "Songs Table"
    debug_write "Testing access to songs table..."

    if ! event_run mysql radiodj -e "SELECT 1 FROM songs LIMIT 1;" >/dev/null 2>&1; then
        status_failure "Songs Table (not accessible)"
        return 1
    fi

    status_success "Songs Table"
    return 0
}

# Count rows in a table with optional WHERE clause
# $1: table name
# $2: optional WHERE clause
# Returns: count on success, empty on failure
db_count() {
    local table_name="$1"
    local where_clause="${2:-}"
    local query="SELECT COUNT(*) FROM ${table_name}"
    local result
    
    # Add WHERE clause if provided
    if [[ -n "$where_clause" ]]; then
        query="${query} WHERE ${where_clause}"
    fi
    
    debug_write "Executing count query..."
    result=$(event_run mysql -N -B radiodj -e "$query" 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        debug_write "Count query failed"
        return 1
    fi
    
    echo "$result"
    return 0
}

# Helper functions for escaping and validation

# Escape a string for SQL query safety
# $1: string to escape
# Returns: escaped string
db_escape_string() {
    local string="$1"
    printf '%s' "${string//\'/\'\\\'\'}"
}

# Check if a table exists in the database
# $1: table name
# Returns: 0 if exists, 1 if not
db_table_exists() {
    local table_name="$1"
    local result
    
    debug_write "Checking table existence..."
    result=$(event_run mysql radiodj -N -B -e "SHOW TABLES LIKE '${table_name}';")
    if [[ $? -ne 0 ]]; then
        debug_write "Error checking table existence"
        return 1
    fi

    # Remove whitespace and compare
    result=$(echo "$result" | tr -d '[:space:]')
    [[ "$result" == "$table_name" ]] && return 0
    return 1
}
