#!/bin/bash
# Test suite for state manager module
#
# Verifies:
# 1. State initialization
# 2. Category/subcategory lookups
# 3. Rotation pattern analysis
# 4. Helper function accuracy

set -eu  # Exit on any error and undefined variables

# Source files to test
# shellcheck source=../lib/state_manager.sh
. "$(dirname "$(realpath "$0")")/../lib/state_manager.sh"

# Initialize test environment
init_tests() {
    mkdir -p logs
    export LOG_LEVEL=3  # DEBUG level
    export LOG_FILE="logs/test.log"
    init_logging || {
        echo "Failed to initialize logging"
        exit 1
    }
}

# Test initialization
test_init() {
    log_info "Testing state initialization..."
    
    # Check category loading
    assert "categories loaded" "[[ ${#CATEGORIES[@]} -gt 0 ]]"
    
    # Check subcategory loading
    assert "subcategories loaded" "[[ ${#SUBCATEGORIES[@]} -gt 0 ]]"
    
    # Check rotation loading
    assert "rotations loaded" "[[ ${#ROTATIONS[@]} -gt 0 ]]"
    
    # Check rotation list loading
    assert "rotation lists loaded" "[[ ${#ROTATION_LISTS[@]} -gt 0 ]]"
    
    log_info "State initialization tests completed"
    return 0
}

# Test category lookups
test_categories() {
    log_info "Testing category lookups..."
    
    # Test image category lookup
    local result
    result=$(get_image_category)
    assert "image category found" "[[ '$result' == *'imageID=48'* ]]"
    assert "image parent correct" "[[ '$result' == *'parentID=1'* ]]"
    
    # Test jingle category lookup
    result=$(get_jingle_category)
    assert "jingle category found" "[[ '$result' == *'jingleID=2'* ]]"
    
    # Test commercial category lookup
    result=$(get_commercial_category)
    assert "commercial category found" "[[ '$result' == *'commercialID=5'* ]]"
    
    log_info "Category lookup tests completed"
    return 0
}

# Test rotation pattern analysis
test_rotations() {
    log_info "Testing rotation pattern analysis..."
    
    # Test commercial break detection
    assert "detect commercial break at 00" "is_commercial_break 0"
    assert "detect commercial break at 15" "is_commercial_break 15"
    assert "detect commercial break at 30" "is_commercial_break 30"
    assert "detect commercial break at 45" "is_commercial_break 45"
    assert "reject commercial break at 10" "! is_commercial_break 10"
    
    # Test premium spot detection
    assert "detect premium spot at 14" "is_premium_spot 14"
    assert "detect premium spot at 29" "is_premium_spot 29"
    assert "detect premium spot at 44" "is_premium_spot 44"
    assert "detect premium spot at 59" "is_premium_spot 59"
    assert "reject premium spot at 10" "! is_premium_spot 10"
    
    # Test rotation element retrieval
    local rotation_id=1  # Assuming rotation ID 1 exists
    result=$(get_rotation_elements "$rotation_id")
    assert "rotation elements retrieved" "[[ -n '$result' ]]"
    
    log_info "Rotation pattern analysis tests completed"
    return 0
}

# Test helper for assertions
assert() {
    local message="$1"
    local command="$2"
    
    echo -n "Testing $message... "
    if eval "$command"; then
        echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

# Main test execution
main() {
    init_tests

    test_init
    test_categories
    test_rotations

    log_info "All state manager tests completed successfully!"
    return 0
}

# Run tests
main "$@"

