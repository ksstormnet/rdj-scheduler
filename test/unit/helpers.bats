#!/usr/bin/env bats

load '../test_helper.bash'

@test "create_test_file helper creates a file with content" {
    local test_content="hello world"
    local temp_file
    temp_file=$(create_test_file "$test_content")
    
    assert [ -f "$temp_file" ]
    run cat "$temp_file"
    assert_output "$test_content"
    rm -f "$temp_file"
}

@test "get_script_dir helper returns correct script directory" {
    local script_name="test.sh"
    local expected_dir="$PROJECT_ROOT/scripts/$script_name"
    
    run get_script_dir "$script_name"
    assert_output "$expected_dir"
}
