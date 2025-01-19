#!/usr/bin/env bats

load '../test_helper.bash'

setup() {
    TEST_DB=""
}

teardown() {
    if [ -n "$TEST_DB" ]; then
        teardown_test_db "$TEST_DB"
    fi
}

@test "mock database can be created and destroyed" {
    TEST_DB=$(setup_test_db)
    assert [ -n "$TEST_DB" ]
    
    # Verify database exists
    run mysql -N -B -e "SHOW DATABASES LIKE '${TEST_DB}'"
    assert_output "$TEST_DB"
    
    # Clean up
    teardown_test_db "$TEST_DB"
    
    # Verify database is gone
    run mysql -N -B -e "SHOW DATABASES LIKE '${TEST_DB}'"
    assert_output ""
}

@test "mock database contains expected tables" {
    TEST_DB=$(setup_test_db)
    
    # Check each required table exists
    for table in category subcategory events rotations rotations_list; do
        run query_test_db "$TEST_DB" "SHOW TABLES LIKE '${table}'"
        assert_output "$table"
    done
}

@test "mock data contains expected sample records" {
    TEST_DB=$(setup_test_db)
    
    # Check category count
    run count_records "$TEST_DB" "category"
    assert_output "3"
    
    # Check subcategory count
    run count_records "$TEST_DB" "subcategory"
    assert_output "4"
    
    # Check rotations count
    run count_records "$TEST_DB" "rotations"
    assert_output "3"
    
    # Check rotation_list count
    run count_records "$TEST_DB" "rotations_list"
    assert_output "3"
    
    # Check events count
    run count_records "$TEST_DB" "events"
    assert_output "3"
}

@test "mock data maintains proper relationships" {
    TEST_DB=$(setup_test_db)
    
    # Test subcategory to category relationship
    run query_test_db "$TEST_DB" "SELECT COUNT(*) FROM subcategory s JOIN category c ON s.parentid = c.ID"
    assert_output "4"
    
    # Test rotations_list to category relationship
    run query_test_db "$TEST_DB" "SELECT COUNT(*) FROM rotations_list r JOIN category c ON r.catID = c.ID"
    assert_output "3"
    
    # Test rotations_list to subcategory relationship
    run query_test_db "$TEST_DB" "SELECT COUNT(*) FROM rotations_list r JOIN subcategory s ON r.subID = s.ID"
    assert_output "3"
    
    # Test rotations_list to rotations relationship
    run query_test_db "$TEST_DB" "SELECT COUNT(*) FROM rotations_list r JOIN rotations rot ON r.pID = rot.ID"
    assert_output "3"
}
