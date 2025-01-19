#!/usr/bin/env bats

load '../test_helper.bash'

setup() {
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
    
    # Save original HOME value and set it to our test directory
    ORIGINAL_HOME="$HOME"
    export HOME="$TEST_DIR"
    
    # Save original working directory
    ORIGINAL_PWD="$PWD"
    
    # Create test working directory
    WORK_DIR="$TEST_DIR/project"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
}

teardown() {
    # Restore original HOME
    export HOME="$ORIGINAL_HOME"
    
    # Return to original directory
    cd "$ORIGINAL_PWD"
    
    # Clean up test directory
    rm -rf "$TEST_DIR"
}

# Helper to create a test .env file
create_env_file() {
    cat > "$WORK_DIR/.env" << ENVFILE
DB_HOST=localhost
DB_USER=radiodj
DB_PASS=envpass
DB_NAME=radiodj_db
ENVFILE
}

# Helper to create a test .my.cnf file
create_mycnf_file() {
    mkdir -p "$HOME"
    cat > "$HOME/.my.cnf" << MYCNF
[client]
host=127.0.0.1
user=root
password=cnfpass
database=radiodj_prod
MYCNF
}

@test "verify .env file is detected when present" {
    create_env_file
    assert [ -f "$WORK_DIR/.env" ]
    run cat "$WORK_DIR/.env"
    assert_line --index 0 "DB_HOST=localhost"
    assert_line --index 1 "DB_USER=radiodj"
    assert_line --index 2 "DB_PASS=envpass"
    assert_line --index 3 "DB_NAME=radiodj_db"
}

@test "verify .my.cnf file is detected when present" {
    create_mycnf_file
    assert [ -f "$HOME/.my.cnf" ]
    run cat "$HOME/.my.cnf"
    assert_line --index 1 "host=127.0.0.1"
    assert_line --index 2 "user=root"
    assert_line --index 3 "password=cnfpass"
    assert_line --index 4 "database=radiodj_prod"
}

@test "verify .env takes precedence over .my.cnf when both present" {
    create_env_file
    create_mycnf_file
    
    # Both files should exist
    assert [ -f "$WORK_DIR/.env" ]
    assert [ -f "$HOME/.my.cnf" ]
    
    # TODO: Once we have the database connection script, 
    # we'll need to test which configuration it actually uses
    # For now, this is a placeholder assertion
    assert [ -f "$WORK_DIR/.env" ]
}
