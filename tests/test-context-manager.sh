#!/bin/bash
#
# Context Manager Tests for RadioDJ
# Tests context management functions for category/subcategory handling

set -euo pipefail
IFS=$'\n\t'

# Get repo root directory and ensure consistent pathing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SCRIPT_DIR

# Set up environment variables
export is_debug=true
export LOG_FORMAT='[%datetime%] [%level%] %message%'

# Set up logging constants
declare -gr LOG_LEVEL_DEBUG=7
declare -gr LOG_FILE="${SCRIPT_DIR}/logs/test.log"

# Source dependencies using repo root paths
# shellcheck source=/dev/null
{
    source "${SCRIPT_DIR}/lib/logging.sh"
    source "${SCRIPT_DIR}/lib/display-helpers.sh" 
    source "${SCRIPT_DIR}/db/db-interface.sh"
    source "${SCRIPT_DIR}/lib/context-manager.sh"
}

# Initialize logging
init_logging "${LOG_FILE}" "${LOG_LEVEL_DEBUG}"
# Define expected category structure
# Format: "category_id:category:subcategory_id:subcategory"
readonly EXPECTED_CATEGORIES=(
    # Music Categories
    "1:Music:45:CE - Core Early - 78  to 83"
    "1:Music:47:CL - Core Late - 89  to 93"
    "1:Music:46:CM - Core Mid - 84 to 88"
    "1:Music:49:G - Pre-78"
    "1:Music:48:I - Image"
    "1:Music:53:M - Modern - Post -94"
    "1:Music:56:PB -  Power Ballad"
    "1:Music:50:SCh - Christian"
    "1:Music:51:SCo - Country"
    "1:Music:52:SD - Disco"
    "1:Music:54:SP - Pop"
    "1:Music:55:SR - Rock"
    # Commercial Categories
    "7:Commercials:31:15"
    "7:Commercials:30:30"
    "7:Commercials:32:60"
    # Jingle Categories
    "5:Jingles:35:B - Between"
    "5:Jingles:34:tM - to Music"
    # Promo Categories
    "6:Promos:57:TOH"
    # Station ID Categories
    "4:Station IDs:41:ID Jingle"
)
# Initialize context manager
test_init_context() {
    local msg="Context: init"
    status_testing "${msg}"
    
    if ! init_context; then
        status_failure "${msg}"
        return 1
    fi

    status_success "${msg}"
    return 0
}
# Verify required categories are present and match expected structure
test_required_categories() {
    local msg="Context: categories"
    status_testing "${msg}"
    local missing=0
    local unexpected=0
    local current_categories
    current_categories=$(context_get_all_categories)
    
    # Check each expected category exists
    local exp_cat_id exp_cat exp_sub_id exp_sub
    for expected in "${EXPECTED_CATEGORIES[@]}"; do
        IFS=':' read -r exp_cat_id exp_cat exp_sub_id exp_sub <<< "${expected}"
        if ! echo "${current_categories}" | grep -q "^${exp_cat_id}[[:space:]]*${exp_cat}[[:space:]]*${exp_sub_id}[[:space:]]*${exp_sub}$"; then
            log_error "Missing or mismatched category: ${exp_cat}/${exp_sub}"
            missing=1
        fi
    done

    # Check for unexpected categories
    local cat_id category sub_id subcategory found
    while IFS=$'\t' read -r cat_id category sub_id subcategory; do
        found=0
        for expected in "${EXPECTED_CATEGORIES[@]}"; do
            IFS=':' read -r exp_cat_id exp_cat exp_sub_id exp_sub <<< "${expected}"
            if [[ "${cat_id}" == "${exp_cat_id}" && "${category}" == "${exp_cat}" && \
                "${sub_id}" == "${exp_sub_id}" && "${subcategory}" == "${exp_sub}" ]]; then
                found=1
                break
            fi
        done
        if ((found == 0)); then
            log_error "Unexpected category found: ${category}/${subcategory}"
            unexpected=1
        fi
    done < <(context_get_all_categories)

    # Return results
    if ((missing == 1 || unexpected == 1)); then
        status_failure "${msg}"
        return 1
    fi

    status_success "${msg}"
    return 0
}
# Verify category IDs are valid
test_category_ids() {
    local msg="Context: IDs"
    status_testing "${msg}"
    local invalid=0
    local cat_id category subcat_id subcategory
    
    while IFS=$'\t' read -r cat_id category subcat_id subcategory; do
        if ! [[ "${cat_id}" =~ ^[0-9]+$ ]] || ! [[ "${subcat_id}" =~ ^[0-9]+$ ]]; then
            log_error "Invalid ID for ${category}/${subcategory}: cat_id=${cat_id}, subcat_id=${subcat_id}"
            invalid=1
        fi
    done < <(context_get_all_categories)

    if ((invalid == 1)); then
        status_failure "${msg}"
        return 1
    fi

    status_success "${msg}"
    return 0
}

# Test: Verify event type compatibility
test_event_type_compatibility() {
    status_testing "Context: event compatibility"

    # Verify all categories are used in type=2 events
    local unused=0
    while IFS=$'\t' read -r cat_id category sub_id subcategory; do
        if ! context_category_used_in_events "$cat_id" "$sub_id" 2; then
            log_error "Category not used in type 2 events: ${category}/${subcategory}"
            unused=1
        fi
    done < <(context_get_all_categories)

    if [ $unused -eq 1 ]; then
        status_failure "Unused categories found"
        return 1
    fi

    status_success "Context: event compatibility"
}

# Test: Verify context handles database errors gracefully
test_error_handling() {
    status_testing "Context: error handling"
    local failed=0
    local result
    local total_tests=4
    log_info "Starting error handling tests..."

    # Test 1: Empty message validation
    log_info "Testing empty message validation..."
    result=$(log_error "" 2>&1)
    if [[ ! "$result" =~ "Empty message passed to log_message" ]]; then
        log_error "Empty message validation failed - expected error message not received"
        log_error "Got: $result"
        ((failed++))
    else
        log_info "Empty message properly validated with error message"
    fi

    # Test 2: Database connection failure
    log_info "Testing database connection failure..."
    if ! context_test_connection_failure >/dev/null 2>&1; then
        log_info "Database connection failure properly detected"
    else
        log_error "Database connection failure test unexpectedly succeeded"
        ((failed++))
    fi

    # Test 3: Invalid category data tests
    log_info "Testing invalid category data..."
    if ! context_test_invalid_category_data; then
        log_error "Failed to properly validate invalid category data"
        ((failed++))
    else
        log_info "Invalid category data properly rejected"
    fi

    # Test 4: Error recovery test
    log_info "Testing error recovery..."
    if ! context_test_error_recovery; then
        log_error "Failed to recover from error state"
        ((failed++))
    else
        log_info "Successfully recovered from error state"
    fi

    # Summary reporting
    log_info "Error handling test summary:"
    log_info "Total tests run: $total_tests"
    log_info "Failed tests: $failed"
    log_info "Passed tests: $((total_tests - failed))"

    if [ $failed -gt 0 ]; then
        status_failure "Error handling tests failed ($failed failures)"
        return 1
    fi

    log_info "All error handling tests passed successfully"
    status_success "Context: error handling"
    return 0
}

# Test: Verify all required data relationships exist
test_data_completeness() {
    status_testing "Context: completeness"

    # Verify all categories have required subcategories
    local missing=0
    for expected in "${EXPECTED_CATEGORIES[@]}"; do
        IFS=':' read -r cat_id cat sub_id sub <<< "$expected"
        if ! context_verify_subcategory_exists "$cat_id" "$sub_id"; then
            log_error "Missing subcategory relationship: ${cat}/${sub}"
            missing=1
        fi
    done

    # Verify all required relationships for rotation building exist
    if ! context_verify_rotation_relationships; then
        log_error "Missing relationships required for rotation building"
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        status_failure "Incomplete data relationships"
        return 1
    fi

    status_success "Context: completeness"
}

# Test: Verify consistency of category IDs and relationships
test_id_consistency() {
    status_testing "Context: ID consistency"

    local inconsistent=0
    while IFS=$'\t' read -r cat_id category sub_id subcategory; do
        # Verify parent category ID is in valid range
        if ! [[ "$cat_id" =~ ^[1-7]$ ]]; then
            log_error "Category ID out of range: $cat_id for $category"
            inconsistent=1
        fi

        # Verify subcategory ID is in valid range (30-60)
        if ! [[ "$sub_id" =~ ^[0-9]+$ ]] || [ "$sub_id" -lt 30 ] || [ "$sub_id" -gt 60 ]; then
            log_error "Subcategory ID out of range: $sub_id for $subcategory"
            inconsistent=1
        fi

        # Verify parent-child relationship exists in database
        if ! context_verify_category_relationship "$cat_id" "$sub_id"; then
            log_error "Invalid category relationship: $category -> $subcategory"
            inconsistent=1
        fi

        # Additional checks from second implementation
        if ! context_verify_relationship "$cat_id" "$sub_id"; then
            log_error "Invalid relationship: $category/$subcategory"
            inconsistent=1
        fi
    done < <(context_get_all_categories)

    if [ $inconsistent -eq 1 ]; then
        status_failure "Inconsistent category structure"
        return 1
    fi

    status_success "Context: ID consistency"
}

# Test: Verify data validation rules
test_data_validation() {
    status_testing "Context: validation"

    local invalid=0

    # Verify category name formats
    while IFS=$'\t' read -r _ category _ subcategory; do
        if ! [[ "$category" =~ ^[A-Za-z][A-Za-z[:space:]]*[A-Za-z]$ ]]; then
            log_error "Invalid category name format: $category"
            invalid=1
        fi
        if ! [[ "$subcategory" =~ ^[A-Za-z0-9[:space:]\-]+$ ]]; then
            log_error "Invalid subcategory name format: $subcategory"
            invalid=1
        fi
    done < <(context_get_all_categories)

    # Verify no duplicate category/subcategory combinations
    local dupes
    dupes=$(context_get_all_categories | awk -F'\t' '{print $2"/"$4}' | sort | uniq -d)
    if [ -n "$dupes" ]; then
        log_error "Duplicate category combinations found:"
        echo "$dupes" | while IFS= read -r dupe; do
            log_error "  $dupe"
        done
        invalid=1
    fi

    # Verify all required relationships for rotation building
    if ! context_validate_rotation_requirements; then
        log_error "Failed rotation building requirements validation"
        invalid=1
    fi

    if [ $invalid -eq 1 ]; then
        status_failure "Data validation failed"
        return 1
    fi

    status_success "Context: validation"
  }

# Test: Verify no duplicate categories exist
test_no_duplicates() {
    status_testing "Context: duplicates"

    local dupes
    dupes=$(context_get_all_categories | awk -F'\t' '{print $2"/"$4}' | sort | uniq -d)

    if [ -n "$dupes" ]; then
        log_error "Duplicate categories found:"
        while IFS= read -r dupe; do
            log_error "  $dupe"
        done <<< "$dupes"
        status_failure "Duplicate categories exist"
        return 1
    fi

    status_success "Context: duplicates"
}

# Run all tests
main() {
    test_init_context || return 1
    test_required_categories || return 1
    test_category_ids || return 1
    test_no_duplicates || return 1
    test_event_type_compatibility || return 1
    test_error_handling || return 1
    test_data_completeness || return 1
    test_id_consistency || return 1
    test_data_validation || return 1

    log_info "All context manager tests passed"
    return 0
}
# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
