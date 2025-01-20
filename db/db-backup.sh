#!/bin/bash

# Use BACKUP_DIR from main script, fallback to 'backups' if not set
BACKUP_DIR="${BACKUP_DIR:-backups}"
DB_NAME="radiodj"
db_backup() {
    local table_name="$1"
    
    # Validate table name parameter
    if [ -z "$table_name" ]; then
        log_error "Table name is required"
        return 1
    fi
    
    # Create backups directory if it doesn't exist
    mkdir -p "$BACKUP_DIR" || {
        log_error "Failed to create backup directory: $BACKUP_DIR"
        return 1
    }
    
    # Generate backup filename with current date
    local date_str
    date_str=$(date +%Y-%m-%d)
    local backup_file="$BACKUP_DIR/${table_name}-${date_str}.sql"

    # Backup the specified table
    log_info "Backing up table: $table_name to $backup_file"
    mysqldump "$DB_NAME" "$table_name" > "$backup_file" 2>/dev/null || {
        log_error "Failed to backup table $table_name"
        return 1
    }

    log_info "Backup completed successfully: $backup_file"
    return 0
}

db_backup_multi() {
    # Check if any table names were provided
    if [ $# -eq 0 ]; then
        log_error "At least one table name is required"
        return 1
    fi

    # Create backups directory if it doesn't exist
    mkdir -p "$BACKUP_DIR" || {
        log_error "Failed to create backup directory: $BACKUP_DIR"
        return 1
    }

    # Generate backup filename with current date
    local date_str
    date_str=$(date +%Y-%m-%d)
    local backup_file="$BACKUP_DIR/${date_str}-backup.sql"

    # Backup the specified tables
    log_info "Backing up tables: $* to $backup_file"
    mysqldump "$DB_NAME" "$@" > "$backup_file" 2>/dev/null || {
        log_error "Failed to backup tables: $*"
        return 1
    }

    log_info "Backup completed successfully: $backup_file"
    return 0
}

db_backup_schema_and_sample() {
    local table_name="$1"
    
    # Validate table name parameter
    if [ -z "$table_name" ]; then
        log_error "Table name is required"
        return 1
    fi
    
    # Create backups directory if it doesn't exist
    mkdir -p "$BACKUP_DIR" || {
        log_error "Failed to create backup directory: $BACKUP_DIR"
        return 1
    }
    
    # Generate backup filename with current date
    local date_str
    date_str=$(date +%Y-%m-%d)
    local backup_file="$BACKUP_DIR/${table_name}-schema-sample-${date_str}.sql"

    # Backup the specified table with schema and first row only
    log_info "Backing up schema and sample from table: $table_name to $backup_file"
    # Backup the table schema and first row using mysqldump with options:
    # --single-transaction : Ensures consistency by wrapping in a transaction
    # --no-tablespaces    : Improves portability across MySQL versions
    # --extended-insert=FALSE : One INSERT statement per row for readability
    # --where="1 LIMIT 1" : Only backup the first row of data
    mysqldump --single-transaction \
            --no-tablespaces \
            --extended-insert=FALSE \
            "$DB_NAME" "$table_name" \
            --where="1 LIMIT 1" > "$backup_file" 2>/dev/null || {
        log_error "Failed to backup table $table_name"
        return 1
    }

    log_info "Schema and sample backup completed successfully: $backup_file"
    return 0
}
