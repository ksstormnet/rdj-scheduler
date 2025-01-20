#!/bin/bash

# Copyright (c) 2025 Sky+Sea, LLC d/b/a KSStorm Media
# Licensed under the MIT License
# Database testing functionality for RadioDJ Scheduler

set -euo pipefail
IFS=$'\n\t'

# Tests database connection settings and ensures connectivity
test_database_connection() {
    status_testing "Testing database connection..."
    
    if [ ! -f "${HOME}/.my.cnf" ]; then
        status_failure "MySQL configuration file not found"
        return 1
    fi
    
    local test_query="SELECT VERSION()"
    if ! db_select "$test_query" >/dev/null 2>&1; then
        status_failure "Database connection test failed"
        return 1
    fi
    
    status_success "Database connection test successful"
    return 0
}

# Tests if the songs table exists and has correct structure
test_songs_table() {
    status_testing "Testing songs table"
    if ! db_table_exists "songs"; then
        status_failure "Songs table does not exist"
        return 1
    fi

    local test_query="SHOW COLUMNS FROM songs"
    debug_write "Checking songs table columns"
    if ! db_select "$test_query" | grep -q "title"; then
        status_failure "Songs table is missing required columns"
        return 1
    fi

    status_success "Songs table test successful"
    return 0
}
