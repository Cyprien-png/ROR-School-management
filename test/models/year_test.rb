require "test_helper"

class YearTest < ActiveSupport::TestCase
  setup do
    # Create a year with trimesters
    @year = Year.create!(
      first_trimester: Trimester.create!(start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31)),
      second_trimester: Trimester.create!(start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31)),
      third_trimester: Trimester.create!(start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30)),
      fourth_trimester: Trimester.create!(start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31))
    )

    # Create an archived year
    @archived_year = Year.create!(
      first_trimester: Trimester.create!(start_date: Date.new(2023,8,1), end_date: Date.new(2023,10,31)),
      second_trimester: Trimester.create!(start_date: Date.new(2023,11,1), end_date: Date.new(2024,1,31)),
      third_trimester: Trimester.create!(start_date: Date.new(2024,2,1), end_date: Date.new(2024,4,30)),
      fourth_trimester: Trimester.create!(start_date: Date.new(2024,5,1), end_date: Date.new(2024,7,31))
    )
    @archived_year.update_column(:isDeleted, true)
  end

  test "should validate sequential trimester dates" do
    year = Year.new(
      first_trimester_attributes: { start_date: Date.new(2024,8,1), end_date: Date.new(2024,11,1) },
      second_trimester_attributes: { start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31) },
      third_trimester_attributes: { start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30) },
      fourth_trimester_attributes: { start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31) }
    )
    assert_not year.valid?
    assert_includes year.errors.full_messages, "Trimester dates must be sequential and not overlap"
  end

  test "should create valid year with sequential dates" do
    year = Year.new(
      first_trimester_attributes: { start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31) },
      second_trimester_attributes: { start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31) },
      third_trimester_attributes: { start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30) },
      fourth_trimester_attributes: { start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31) }
    )
    assert year.valid?
  end

  test "should not show soft deleted years in default scope" do
    assert_not_includes Year.all, @archived_year
    assert_includes Year.with_deleted, @archived_year
  end

  test "should soft delete year" do
    @year.soft_delete
    assert @year.isDeleted
    assert_not_includes Year.all, @year
    assert_includes Year.with_deleted, @year
  end
end
