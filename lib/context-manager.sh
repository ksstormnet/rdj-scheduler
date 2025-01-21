#!/bin/bash

# Context Manager for RadioDJ
# Handles database context validation and category relationships

set -euo pipefail
IFS=$'\n\t'

# Get repo root directory 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source dependencies using repo root paths
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/db/db-interface.sh"
init_context() {
    # Test database connection
    if ! db_test_connection; then
        log_error "Failed to connect to database"
        return 1
    fi

    # Verify critical tables exist
    local required_tables=("category" "subcategory" "events" "events_categories" "rotations" "rotations_list")
    local missing=()

    for table in "${required_tables[@]}"; do
        if ! db_table_exists "$table"; then
            missing+=("$table")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        log_error "Missing required tables: ${missing[*]}"
        return 1
    fi

    return 0
}
context_get_all_categories() {
    local sql_file="${SCRIPT_DIR}/required-categories.sql"
    
    # Verify SQL file exists
    if [[ ! -f "$sql_file" ]]; then
        log_error "Required categories SQL file not found: $sql_file"
        return 1
    fi

    # Execute SQL query
    local query
    if ! query=$(cat "$sql_file"); then
        log_error "Failed to read SQL file: $sql_file"
        return 1
    fi

    if ! db_select "$query"; then
        log_error "Failed to fetch required categories"
        return 1
    fi

    return 0
}
context_verify_relationship() {
    local cat_id="$1"
    local sub_id="$2"
    # Check relationship in subcategory table
    db_select "SELECT 1 FROM subcategory WHERE parentid=$cat_id AND id=$sub_id LIMIT 1"
}

context_verify_category_relationship() {
    local cat_id="$1"
    local sub_id="$2"
    # Check relationship in subcategory table
    db_select "SELECT 1 FROM subcategory WHERE parentid=$cat_id AND id=$sub_id LIMIT 1"
}

context_verify_subcategory_exists() {
    local cat_id="$1"
    local sub_id="$2"
    db_select "SELECT 1 FROM subcategory WHERE parentid=$cat_id AND id=$sub_id LIMIT 1"
}

context_verify_rotation_relationships() {
    # Use catID and subID to match the schema seen in required-categories.sql
    db_select "SELECT 1 FROM rotations_list rl WHERE rl.catID IN (SELECT ID FROM category) LIMIT 1"
}

context_validate_rotation_requirements() {
    local query="SELECT COUNT(*) FROM rotations r JOIN rotations_list rl ON r.ID = rl.pID"
    local count
    count=$(db_select "$query")
    if [[ -z "$count" ]]; then
        return 1
    fi
    # Return success if count > 0, handle possible leading spaces
    test "$((count))" -gt 0
    return $?
}

context_category_used_in_events() {
    local cat_id="$1"
    local sub_id="$2"
    local event_type="${3:-2}"  # 2 is Preload
    # Check if category/subcategory is used in preload events via rotations
    db_select "
        SELECT 1 
        FROM events e 
        JOIN rotations r ON e.data LIKE '%\"rotation\":'||r.ID||'%'
        JOIN rotations_list rl ON r.ID = rl.pID 
        WHERE e.type = $event_type 
        AND e.enabled = 'True'
        AND rl.catID = $cat_id 
        AND rl.subID = $sub_id
        LIMIT 1"
}
context_test_connection_failure() {
    local orig_port=${MYSQL_TCP_PORT:-}
    
    # Force connection failure
    export MYSQL_TCP_PORT=1
    
    # Attempt query that should fail
    local result=0
    if ! db_select "SELECT 1" >/dev/null 2>&1; then
        log_info "Connection failure test succeeded"
        result=1
    else
        log_error "Database connection should have failed"
    fi
    
    # Restore original port
    if [[ -n "$orig_port" ]]; then
        export MYSQL_TCP_PORT="$orig_port"
    else
        unset MYSQL_TCP_PORT
    fi
    
    return $result
}
context_test_error_recovery() {
    if ! db_begin; then
        log_error "Failed to begin transaction"
        return 1
    fi

    # Test invalid operation
    log_info "Testing invalid table query..."
    if db_select "SELECT * FROM invalid_table" >/dev/null 2>&1; then
        log_error "Invalid table query should have failed"
        db_rollback
        return 1
    fi
    log_info "Invalid table error detected as expected"

    # Test recovery
    log_info "Testing recovery..."
    if ! context_get_all_categories >/dev/null; then
        log_error "Failed to recover after error"
        db_rollback
        return 1
    fi
    log_info "Recovery successful"

    db_rollback
    return 0
}

# Test various invalid category data scenarios
context_test_invalid_category_data() {
    local error_count=0
    local test_output
    local rc
    local total_tests=5

    db_begin || {
        log_error "Failed to begin transaction"
        return 1
    }
    
    log_info "Starting invalid category data tests..."
    
    # Test 1: Empty category name
    log_info "Testing empty category name..."
    if test_output=$(db_execute "INSERT INTO category (name, enabled) VALUES ('', 1)" 2>&1); then
        rc=$?
        log_error "Empty category name insertion should have failed (rc=$rc)"
        log_error "Output: $test_output" 
        ((error_count++))
    else
        log_info "Empty category name correctly rejected"
    fi
    
    # Test 2: Invalid category ID format
    log_info "Testing invalid category ID format..."
    if test_output=$(db_execute "UPDATE category SET id='ABC' WHERE id=1" 2>&1); then
        rc=$?
        log_error "Invalid ID update should have failed (rc=$rc)"
        log_error "Output: $test_output"
        ((error_count++))
    else
        log_info "Invalid ID format correctly rejected"
    fi
    
    # Test 3: Invalid event type
    log_info "Testing invalid event type..."
    if test_output=$(db_execute "INSERT INTO events (type) VALUES (9999)" 2>&1); then
        rc=$?
        log_error "Invalid event type insertion should have failed (rc=$rc)"
        log_error "Output: $test_output"
        ((error_count++))
    else
        log_info "Invalid event type correctly rejected"
    fi
    
    # Test 4: Orphaned reference check
    log_info "Testing orphaned references..."
    if test_output=$(db_execute "INSERT INTO subcategory (id, category_id) VALUES (999, 999)" 2>&1); then
        rc=$?
        log_error "Orphaned reference insertion should have failed (rc=$rc)"
        log_error "Output: $test_output"
        ((error_count++))
    else
        log_info "Orphaned reference correctly rejected"
    fi
    
    # Test 5: SQL injection attempt
    log_info "Testing SQL injection prevention..."
    if test_output=$(db_execute "UPDATE category SET name='test' WHERE id='1' OR '1'='1'" 2>&1); then
        rc=$?
        log_error "SQL injection attempt should have failed (rc=$rc)"
        log_error "Output: $test_output"
        ((error_count++))
    else
        log_info "SQL injection attempt correctly rejected"
    fi

    db_rollback
    
    # Test Summary
    log_info "Invalid category data test summary:"
    log_info "Total tests run: $total_tests"
    log_info "Failed validations: $error_count"
    log_info "Passed validations: $((total_tests - error_count))"
    
    # If no errors were detected from the database operations, that's good
    # If no errors were detected from the database operations, that's good
    # as all invalid operations should fail
    if [ $error_count -gt 0 ]; then
        log_error "$error_count invalid operations succeeded when they should have failed"
        return 1
    fi

    return 0
}
