require "application_system_test_case"

class LecturesTest < ApplicationSystemTestCase
  setup do
    @lecture = lectures(:one)
  end

  test "visiting the index" do
    visit lectures_url
    assert_selector "h1", text: "Lectures"
  end

  test "should create lecture" do
    visit lectures_url
    click_on "New lecture"

    fill_in "End time", with: @lecture.end_time
    fill_in "Start time", with: @lecture.start_time
    fill_in "Week day", with: @lecture.week_day
    click_on "Create Lecture"

    assert_text "Lecture was successfully created"
    click_on "Back"
  end

  test "should update Lecture" do
    visit lecture_url(@lecture)
    click_on "Edit this lecture", match: :first

    fill_in "End time", with: @lecture.end_time.to_s
    fill_in "Start time", with: @lecture.start_time.to_s
    fill_in "Week day", with: @lecture.week_day
    click_on "Update Lecture"

    assert_text "Lecture was successfully updated"
    click_on "Back"
  end

  test "should destroy Lecture" do
    visit lecture_url(@lecture)
    click_on "Destroy this lecture", match: :first

    assert_text "Lecture was successfully destroyed"
  end
end
