require "application_system_test_case"

class LecturesTest < ApplicationSystemTestCase
  setup do
    @dean = create_dean
    @subject = create_subject
    @trimester = create_trimester
    @lecture = create_lecture(@subject)
    sign_in @dean
  end

  test "visiting the index" do
    visit lectures_url
    assert_selector "h1", text: "Lectures"
  end

  test "should create lecture" do
    visit lectures_url
    click_on "New lecture"

    fill_in "Start time", with: "09:00"
    fill_in "End time", with: "10:30"
    select "Monday", from: "Week day"
    select @subject.name, from: "Subject"
    select "#{@trimester.start_date.strftime('%B %d, %Y')} - #{@trimester.end_date.strftime('%B %d, %Y')}", from: "Trimesters"

    click_on "Create Lecture"

    assert_text "Lecture was successfully created"
    click_on "Back"
  end

  test "should update Lecture" do
    visit lecture_url(@lecture)
    click_on "Edit this lecture", match: :first

    fill_in "Start time", with: "11:00"
    fill_in "End time", with: "12:30"
    select "Tuesday", from: "Week day"
    
    # Create a new trimester for testing update
    new_trimester = create_trimester(Date.new(2024,11,1), Date.new(2025,1,31))
    select "#{new_trimester.start_date.strftime('%B %d, %Y')} - #{new_trimester.end_date.strftime('%B %d, %Y')}", from: "Trimesters"

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
