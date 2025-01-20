#!/bin/bash

# Copyright (c) 2025 Sky+Sea, LLC d/b/a KSStorm Media
# Licensed under the MIT License
# Database testing functionality for RadioDJ Scheduler

set -euo pipefail
IFS=$'\n\t'

# Tests database connection settings and ensures connectivity
test_database_connection() {
    status_testing "DB: connect"

    if [ ! -f "${HOME}/.my.cnf" ]; then
        status_failure "Config file not found at ${HOME}/.my.cnf"
        return 1
    fi
    debug_write "Found MySQL configuration file"

    local version test_query="SELECT VERSION()" test_output
    if ! test_output=$(db_select "$test_query" 2>&1); then
        status_failure "Connection failed - check MySQL config"
        debug_write "Failed to execute: $test_query"
        debug_write "Error output: $test_output"
        return 1
    fi
    version=$test_output
    debug_write "Database version: $version"
    status_success "DB: connect"
    return 0
}

# Tests if the songs table exists and has correct structure
test_songs_table() {
    status_testing "DB: read"

    if ! db_table_exists "songs"; then
        status_failure "Songs table not found"
        debug_write "Failed to find songs table"
        return 1
    fi
    debug_write "Found songs table"

    # Get total song count
    local test_query="SELECT COUNT(*) FROM songs" count
    if ! count=$(db_select "$test_query" 2>&1); then
        status_failure "Failed to get song count" 
        debug_write "Failed to execute: $test_query"
        debug_write "Error output: $count"
        return 1
    fi
    debug_write "======================================"
    debug_write "Total Songs in Database: $count songs"
    debug_write "======================================"
    debug_write ""

    # Get random sample of songs
    test_query="SELECT id, title, artist FROM songs ORDER BY RAND() LIMIT 5"
    local test_output
    if ! test_output=$(db_select "$test_query" 2>&1); then
        status_failure "Failed to get song samples"
        debug_write "Failed to execute: $test_query" 
        debug_write "Error output: $test_output"
        return 1
    fi

    debug_write "Sample Songs from Database:"
    debug_write "-----------------------------------"
    debug_write "ID    | Title                    | Artist"
    debug_write "-----------------------------------"
    while IFS=$'\t' read -r id title artist; do
        printf -v line "%-5s | %-24s | %s" "$id" "${title:0:24}" "${artist:0:30}"
        debug_write "$line"
    done <<< "$test_output"
    debug_write "-----------------------------------"
    status_success "DB: read"
    return 0
}

# Tests backup functionality by creating and verifying a backup
test_backup() {
    status_testing "DB: backup"

    local backup_file date_str
    date_str=$(date +%Y-%m-%d)
    backup_file="backups/events-schema-sample-${date_str}.sql"

    mkdir -p backups

    if ! db_backup_schema_and_sample "events" >/dev/null 2>&1; then
        status_failure "Failed to create backup"
        debug_write "Backup command failed"
        return 1
    fi

    if [ ! -f "$backup_file" ]; then
        status_failure "Backup file not created"
        debug_write "Expected backup file at: $backup_file"
        return 1
    fi

    if ! grep -q "CREATE TABLE.*events" "$backup_file"; then
        status_failure "Backup missing table structure"
        debug_write "No CREATE TABLE found in backup"
        rm -f "$backup_file"
        return 1
    fi

    if ! grep -q "INSERT INTO.*events" "$backup_file"; then
        status_failure "Backup missing sample data"
        debug_write "No INSERT statements found in backup"
        rm -f "$backup_file"
        return 1
    fi

    debug_write "Backup verified successfully"
    rm -f "$backup_file"
    status_success "DB: backup"
    return 0
}
