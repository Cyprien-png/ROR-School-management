require "test_helper"

class ExaminationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    super
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    
    # Create a subject and assign it to the teacher
    @subject = create_subject
    @teacher.subjects << @subject
    
    # Create a year with trimesters
    @year = Year.create!(
      first_trimester: create_trimester(Date.new(2024,8,1), Date.new(2024,10,31)),
      second_trimester: create_trimester(Date.new(2024,11,1), Date.new(2025,1,31)),
      third_trimester: create_trimester(Date.new(2025,2,1), Date.new(2025,4,30)),
      fourth_trimester: create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
    )
    
    # Create a school class
    @school_class = SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: @year,
      teacher: @teacher
    )
    
    # Create a lecture
    @lecture = Lecture.create!(
      start_time: "09:00",
      end_time: "10:30",
      week_day: :monday,
      subject: @subject,
      teacher: @teacher,
      school_class: @school_class,
      trimesters: [@year.first_trimester]
    )
    
    # Create an examination
    @examination = Examination.create!(
      title: "Test Examination",
      date: Date.new(2024,8,5), # This is a Monday in the first trimester
      lecture: @lecture
    )
  end

  # Authorization Tests

  test "should get index when signed in as dean" do
    sign_in @dean
    get examinations_url
    assert_response :success
  end

  test "should get index when signed in as teacher" do
    sign_in @teacher
    get examinations_url
    assert_response :success
  end

  test "should get index when signed in as student" do
    sign_in @student
    get examinations_url
    assert_response :success
  end

  test "should not get index when not signed in" do
    get examinations_url
    assert_redirected_to new_person_session_path
  end

  test "should get new when signed in as dean" do
    sign_in @dean
    get new_examination_url
    assert_response :success
  end

  test "should get new when signed in as teacher" do
    sign_in @teacher
    get new_examination_url
    assert_response :success
  end

  test "should not get new when signed in as student" do
    sign_in @student
    get new_examination_url
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Creation Tests

  test "should create examination with valid date when signed in as dean" do
    sign_in @dean
    assert_difference("Examination.count") do
      post examinations_url, params: {
        examination: {
          title: "New Examination",
          date: Date.new(2024,8,12), # A Monday in the first trimester
          lecture_id: @lecture.id
        }
      }
    end
    assert_redirected_to examination_url(Examination.last)
  end

  test "should create examination with valid date when signed in as teacher" do
    sign_in @teacher
    assert_difference("Examination.count") do
      post examinations_url, params: {
        examination: {
          title: "New Examination",
          date: Date.new(2024,8,12), # A Monday in the first trimester
          lecture_id: @lecture.id
        }
      }
    end
    assert_redirected_to examination_url(Examination.last)
  end

  test "should not create examination when signed in as student" do
    sign_in @student
    assert_no_difference("Examination.count") do
      post examinations_url, params: {
        examination: {
          title: "New Examination",
          date: Date.new(2024,8,12),
          lecture_id: @lecture.id
        }
      }
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # Date Constraint Tests

  test "should not create examination with date outside trimester" do
    sign_in @dean
    assert_no_difference("Examination.count") do
      post examinations_url, params: {
        examination: {
          title: "Invalid Date Examination",
          date: Date.new(2024,7,1), # Date before trimester starts
          lecture_id: @lecture.id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create examination with wrong weekday" do
    sign_in @dean
    assert_no_difference("Examination.count") do
      post examinations_url, params: {
        examination: {
          title: "Wrong Weekday Examination",
          date: Date.new(2024,8,6), # A Tuesday, but lecture is on Monday
          lecture_id: @lecture.id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Update Tests

  test "should update examination with valid date when signed in as dean" do
    sign_in @dean
    patch examination_url(@examination), params: {
      examination: {
        date: Date.new(2024,8,19) # Another Monday in the first trimester
      }
    }
    assert_redirected_to examination_url(@examination)
    @examination.reload
    assert_equal Date.new(2024,8,19), @examination.date
  end

  test "should update examination with valid date when signed in as teacher" do
    sign_in @teacher
    patch examination_url(@examination), params: {
      examination: {
        date: Date.new(2024,8,19) # Another Monday in the first trimester
      }
    }
    assert_redirected_to examination_url(@examination)
    @examination.reload
    assert_equal Date.new(2024,8,19), @examination.date
  end

  test "should not update examination when signed in as student" do
    sign_in @student
    original_date = @examination.date
    patch examination_url(@examination), params: {
      examination: {
        date: Date.new(2024,8,19)
      }
    }
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
    @examination.reload
    assert_equal original_date, @examination.date
  end

  test "should not update examination with invalid date" do
    sign_in @dean
    original_date = @examination.date
    patch examination_url(@examination), params: {
      examination: {
        date: Date.new(2024,8,6) # A Tuesday, but lecture is on Monday
      }
    }
    assert_response :unprocessable_entity
    @examination.reload
    assert_equal original_date, @examination.date
  end

  # Deletion Tests

  test "should destroy examination when signed in as dean" do
    sign_in @dean
    assert_no_difference("Examination.with_deleted.count") do
      delete examination_url(@examination)
    end
    assert_redirected_to examinations_url
    assert_equal "Examination was successfully archived.", flash[:notice]
    
    # Verify the examination is soft deleted
    @examination.reload
    assert @examination.isDeleted
    
    # Verify the examination is not returned in normal queries
    assert_not Examination.exists?(@examination.id)
    assert Examination.with_deleted.exists?(@examination.id)
  end

  test "should destroy examination when signed in as teacher" do
    sign_in @teacher
    assert_no_difference("Examination.with_deleted.count") do
      delete examination_url(@examination)
    end
    assert_redirected_to examinations_url
    assert_equal "Examination was successfully archived.", flash[:notice]
    
    # Verify the examination is soft deleted
    @examination.reload
    assert @examination.isDeleted
  end

  test "should not destroy examination when signed in as student" do
    sign_in @student
    assert_no_difference("Examination.with_deleted.count") do
      delete examination_url(@examination)
    end
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
    
    # Verify the examination is not deleted
    @examination.reload
    assert_not @examination.isDeleted
  end

  # Available Dates API Tests

  test "should get available dates when signed in as dean" do
    sign_in @dean
    get available_dates_examinations_path(lecture_id: @lecture.id)
    assert_response :success
    
    dates = JSON.parse(response.body)
    assert_not_empty dates
    dates.each do |date|
      date = Date.parse(date)
      assert_equal "Monday", date.strftime("%A") # All dates should be Mondays
      assert @year.first_trimester.start_date <= date
      assert date <= @year.first_trimester.end_date
    end
  end

  test "should get available dates when signed in as teacher" do
    sign_in @teacher
    get available_dates_examinations_path(lecture_id: @lecture.id)
    assert_response :success
  end

  test "should not get available dates when signed in as student" do
    sign_in @student
    get available_dates_examinations_path(lecture_id: @lecture.id)
    assert_redirected_to root_path
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end
end
