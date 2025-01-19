#!/usr/bin/env bats

# Load test helper
load '../test_helper.bash'

@test "verify bats is working" {
    run echo "Hello, World!"
    assert_output "Hello, World!"
    assert_success
}

@test "verify PROJECT_ROOT is set" {
    assert [ -n "$PROJECT_ROOT" ]
    assert [ -d "$PROJECT_ROOT" ]
}
