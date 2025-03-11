require "application_system_test_case"

class YearsTest < ApplicationSystemTestCase
  setup do
    @year = years(:one)
  end

  test "visiting the index" do
    visit years_url
    assert_selector "h1", text: "Years"
  end

  test "should create year" do
    visit years_url
    click_on "New year"

    fill_in "First trimester", with: @year.first_trimester_id
    fill_in "Fourth trimester", with: @year.fourth_trimester_id
    fill_in "Name", with: @year.name
    fill_in "Second trimester", with: @year.second_trimester_id
    fill_in "Third trimester", with: @year.third_trimester_id
    click_on "Create Year"

    assert_text "Year was successfully created"
    click_on "Back"
  end

  test "should update Year" do
    visit year_url(@year)
    click_on "Edit this year", match: :first

    fill_in "First trimester", with: @year.first_trimester_id
    fill_in "Fourth trimester", with: @year.fourth_trimester_id
    fill_in "Name", with: @year.name
    fill_in "Second trimester", with: @year.second_trimester_id
    fill_in "Third trimester", with: @year.third_trimester_id
    click_on "Update Year"

    assert_text "Year was successfully updated"
    click_on "Back"
  end

  test "should destroy Year" do
    visit year_url(@year)
    click_on "Destroy this year", match: :first

    assert_text "Year was successfully destroyed"
  end
end
