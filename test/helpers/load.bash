#!/usr/bin/env bash
# This file can be used to define custom helper functions for tests

# Create a temporary test file
create_test_file() {
    local content="$1"
    local temp_file
    temp_file="$(mktemp)"
    echo "$content" > "$temp_file"
    echo "$temp_file"
}

# Helper to get script directory
get_script_dir() {
    local script_name="$1"
    echo "$PROJECT_ROOT/scripts/$script_name"
}

# Initialize a test database with mock data
setup_test_db() {
    local db_name="test_radiodj_$$"
    local fixtures_dir="$PROJECT_ROOT/test/fixtures"
    mysql -e "CREATE DATABASE ${db_name}"
    mysql "${db_name}" < "${fixtures_dir}/mock_db.sql"
    echo "${db_name}"
}

# Clean up test database
teardown_test_db() {
    local db_name="$1"
    mysql -e "DROP DATABASE IF EXISTS ${db_name}"
}

# Query test database and return results
query_test_db() {
    local db_name="$1"
    local query="$2"
    mysql -N -B "${db_name}" -e "${query}"
}

# Get count of records in a table
count_records() {
    local db_name="$1"
    local table="$2"
    mysql -N -B "${db_name}" -e "SELECT COUNT(*) FROM ${table}"
}
