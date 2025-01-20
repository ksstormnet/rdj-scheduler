#!/bin/bash

# Copyright (c) 2025 Sky+Sea, LLC d/b/a KSStorm Media
# Licensed under the MIT License
# Database interface operations for RadioDJ Scheduler

set -euo pipefail
IFS=$'\n\t'

# Begin a database transaction
db_begin() {
    db_execute "START TRANSACTION"
    return $?
}

# Commit a database transaction
db_commit() {
    db_execute "COMMIT"
    return $?
}

# Rollback a database transaction
db_rollback() {
    db_execute "ROLLBACK"
    return $?
}

# Execute a SELECT query and return results
# $1: SQL query
db_select() {
    local query="$1"
    debug_write "Executing SELECT: ${query}"
    event_run mysql radiodj -N -B -e "$query"
    return $?
}

# Execute a non-SELECT query
# $1: SQL query
db_execute() {
    local query="$1"
    debug_write "Executing query: ${query}"
    event_run mysql radiodj -N -B -e "$query"
    return $?
}

# Count rows in a table
# $1: Table name
# $2: Optional WHERE clause
db_count() {
    local table_name="$1"
    local where_clause="${2:-}"
    local query="SELECT COUNT(*) FROM ${table_name}"
    if [ -n "$where_clause" ]; then
        query="${query} WHERE ${where_clause}"
    fi
    local result=$(db_select "$query")
    echo "$result"
    return 0
}

# Escape a string for safe SQL usage
# $1: String to escape
db_escape_string() {
    local string="$1"
    echo "$string" | sed 's/[\\"'\'']/\\&/g'
    return $?
}

# Check if a table exists in the database
# Check if a table exists in the database
# $1: Table name
db_table_exists() {
    local table_name="$1"
    local query="SHOW TABLES LIKE '${table_name}'"
    debug_write "Checking if table exists: ${table_name}"
    local result=$(db_select "$query" | tr -d '[:space:]')
    if [ -n "$result" ]; then
        return 0
    fi
    return 1
}
