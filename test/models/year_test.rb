require "test_helper"

class YearTest < ActiveSupport::TestCase
  setup do
    # Clean up any existing data
    Year.unscoped.delete_all
    Trimester.unscoped.delete_all
  end

  teardown do
    # Clean up test data
    Year.unscoped.delete_all
    Trimester.unscoped.delete_all
  end

  test "should validate sequential trimester dates" do
    # Create trimesters with overlapping dates
    first = create_trimester(Date.new(2024,8,1), Date.new(2024,11,1))
    second = create_trimester(Date.new(2024,11,1), Date.new(2025,1,31))
    third = create_trimester(Date.new(2025,2,1), Date.new(2025,4,30))
    fourth = create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
    
    # Create a year with these trimesters
    year = Year.new(
      first_trimester: first,
      second_trimester: second,
      third_trimester: third,
      fourth_trimester: fourth
    )
    
    # Validate should fail due to overlapping dates
    assert_not year.valid?
    assert_includes year.errors.full_messages, "Trimester dates must be sequential and not overlap"
  end

  test "should create valid year with sequential dates" do
    # Create trimesters with sequential dates
    first = create_trimester(Date.new(2024,8,1), Date.new(2024,10,31))
    second = create_trimester(Date.new(2024,11,1), Date.new(2025,1,31))
    third = create_trimester(Date.new(2025,2,1), Date.new(2025,4,30))
    fourth = create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
    
    # Create a year with these trimesters
    year = Year.new(
      first_trimester: first,
      second_trimester: second,
      third_trimester: third,
      fourth_trimester: fourth
    )
    
    # Validate should pass
    assert year.valid?
  end

  test "should mark year as deleted when soft deleted" do
    # GIVEN a year in the database
    year = create_year
    assert_not year.isDeleted, "Year should not be marked as deleted initially"
    
    # WHEN soft deleting the year
    year.soft_delete
    
    # THEN the year should be marked as deleted
    year.reload
    assert year.isDeleted, "Year should be marked as deleted"
    assert_not Year.exists?(year.id), "Year should not be found in default scope"
    assert Year.unscoped.exists?(year.id), "Year should still exist in database"
  end

  test "should have with_deleted scope" do
    # GIVEN a year in the database
    year = create_year
    initial_count = Year.count
    
    # WHEN soft deleting the year
    year.soft_delete
    year.reload
    
    # THEN the year should be excluded from default scope but included in with_deleted
    assert_equal initial_count - 1, Year.count, "Year count should decrease by 1"
    assert_equal initial_count, Year.with_deleted.count, "With_deleted count should remain the same"
    assert_not Year.exists?(year.id), "Year should not be found in default scope"
    assert Year.with_deleted.exists?(year.id), "Year should be found in with_deleted scope"
  end
end
