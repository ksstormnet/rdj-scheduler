#!/bin/bash

# Copyright (c) 2025 Sky+Sea, LLC d/b/a KSStorm Media
# Licensed under the MIT License
# Database interface operations for RadioDJ Scheduler

set -euo pipefail
IFS=$'\n\t'

# Execute a non-SELECT query
# Args:
#   $1: SQL query
# Returns:
#   0 on success, non-zero on failure
db_execute() {
    local query="$1"
    log_debug "Executing query: ${query}"
    local output
    output=$(mysql radiodj -N -B -e "$query" 2>&1)
    local rc=$?
    if [ $rc -ne 0 ]; then
        log_error "MySQL query failed: $output"
    else
        log_debug "MySQL query succeeded"
    fi
    return $rc
}

# Commit the current database transaction
# Returns:
#   0 on success, non-zero on failure
db_commit() {
    db_execute "COMMIT"
    return $?
}

# Rollback the current database transaction
# Returns:
#   0 on success, non-zero on failure
db_rollback() {
    db_execute "ROLLBACK"
    return $?
}
# Begin a database transaction
# Returns:
#   0 on success, non-zero on failure
db_begin() {
    db_execute "START TRANSACTION"
    return $?
}


# Execute a SELECT query and return results
# Args:
#   $1: SQL query
# Returns:
#   Query results on success, error message on failure
db_select() {
    local query="$1"
    log_debug "Executing SELECT: ${query}"
    local output
    output=$(mysql radiodj -N -B -e "$query" 2>&1)
    local rc=$?
    if [ $rc -ne 0 ]; then
        log_error "MySQL SELECT failed: $output"
    else
        log_debug "MySQL SELECT succeeded: $output"
    fi
    echo "$output"
    return $rc
}
# Count rows in a table
# Args:
#   $1: Table name
#   $2: Optional WHERE clause
# Returns:
#   Row count on success, error message on failure
db_count() {
    local table_name="$1"
    local where_clause="${2:-}"
    local query="SELECT COUNT(*) FROM ${table_name}"
    if [ -n "$where_clause" ]; then
        query="${query} WHERE ${where_clause}"
    fi
    local result
    result=$(db_select "$query")
    echo "$result"
    return $?
}

# Escape a string for safe SQL usage
# Args:
#   $1: String to escape
# Returns:
#   Escaped string
db_escape_string() {
    local string="$1"
    echo "$string" | sed 's/[\\"'\'']/\\&/g'
    return $?
}

# Tests the database connection by checking version
# This verifies that:
# - MySQL client can connect to server
# - radiodj database is accessible
# - User has proper permissions
# Returns:
#   0 on success, non-zero on failure
# Outputs:
#   MySQL version on success, error message on failure 
db_test_connection() {
    log_info "Testing database connection"
    local output
    output=$(mysql radiodj -e "SELECT version()" 2>&1)
    local rc=$?
    if [ $rc -ne 0 ]; then
        log_error "Database connection test failed: $output"
        return 1
    fi
    debug_write "Database connection successful. MySQL version: $output"
    return 0
}

# Check if a table exists in the radiodj database
# Args:
#   $1: Table name to check
# Returns:
#   0 if table exists
#   1 if table does not exist or error occurs
# Example:
#   if db_table_exists "songs"; then
#     echo "Songs table exists"
#   fi
db_table_exists() {
    local table_name="$1"
    local query="SHOW TABLES LIKE '${table_name}'"
    log_debug "Checking if table exists: ${table_name}"
    local result
    result=$(db_select "$query" 2>&1)
    local rc=$?
    if [ $rc -ne 0 ]; then
        log_error "Failed to check table existence: $result"
        return 1
    fi
    result=$(echo "$result" | tr -d '[:space:]')
    if [ -n "$result" ]; then
        return 0
    fi
    return 1
}
