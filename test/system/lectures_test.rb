require "application_system_test_case"

class LecturesTest < ApplicationSystemTestCase
  setup do
    @dean = create_dean
    @subject = create_subject
    @teacher = create_teacher
    @teacher.subjects << @subject
    
    # Create a year with trimesters
    @year = Year.create!(
      first_trimester: create_trimester(Date.new(2024,8,1), Date.new(2024,10,31)),
      second_trimester: create_trimester(Date.new(2024,11,1), Date.new(2025,1,31)),
      third_trimester: create_trimester(Date.new(2025,2,1), Date.new(2025,4,30)),
      fourth_trimester: create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
    )
    
    # Create a school class with the year
    @school_class = SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: @year,
      teacher: @teacher
    )
    
    # Create a lecture with a trimester from the school class's year
    @lecture = Lecture.create!(
      start_time: "09:00",
      end_time: "10:30",
      week_day: "monday",
      subject: @subject,
      teacher: @teacher,
      school_class: @school_class,
      trimesters: [@year.first_trimester]
    )
    
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
    select @teacher.firstname + " " + @teacher.lastname, from: "Teacher"
    select @school_class.name, from: "Class"
    select "#{@year.first_trimester.start_date.strftime('%B %d, %Y')} - #{@year.first_trimester.end_date.strftime('%B %d, %Y')}", from: "Trimesters"

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
    select "#{@year.second_trimester.start_date.strftime('%B %d, %Y')} - #{@year.second_trimester.end_date.strftime('%B %d, %Y')}", from: "Trimesters"

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
