require "test_helper"

class LecturesControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
  end

  # INDEX TESTS
  
  test "should get index when signed in as dean" do
    dean = create_dean
    sign_in dean
    get lectures_url
    assert_response :success
    assert_select "h1", "Lectures"
  end
  
  test "should get index when signed in as teacher" do
    teacher = create_teacher
    sign_in teacher
    get lectures_url
    assert_response :success
    assert_select "h1", "Lectures"
  end
  
  test "should get index when signed in as student" do
    student = create_student
    sign_in student
    get lectures_url
    assert_response :success
    assert_select "h1", "Lectures"
  end
  
  test "should redirect index when not signed in" do
    get lectures_url
    assert_redirected_to new_person_session_path
  end
  
  # SHOW TESTS
  
  test "should show lecture when signed in as dean" do
    dean = create_dean
    lecture = create_lecture
    sign_in dean
    get lecture_url(lecture)
    assert_response :success
  end
  
  test "should show lecture when signed in as teacher" do
    teacher = create_teacher
    lecture = create_lecture
    sign_in teacher
    get lecture_url(lecture)
    assert_response :success
  end
  
  test "should show lecture when signed in as student" do
    student = create_student
    lecture = create_lecture
    sign_in student
    get lecture_url(lecture)
    assert_response :success
  end
  
  test "should redirect show when not signed in" do
    lecture = create_lecture
    get lecture_url(lecture)
    assert_redirected_to new_person_session_path
  end
  
  # NEW TESTS
  
  test "should get new when signed in as dean" do
    dean = create_dean
    sign_in dean
    get new_lecture_url
    assert_response :success
    assert_select "h1", "New lecture"
  end
  
  test "should not get new when signed in as teacher" do
    teacher = create_teacher
    sign_in teacher
    get new_lecture_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get new when signed in as student" do
    student = create_student
    sign_in student
    get new_lecture_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # CREATE TESTS
  
  test "should create lecture when signed in as dean" do
    dean = create_dean
    subject = create_subject
    teacher = create_teacher
    teacher.subjects << subject
    
    # Create a year with trimesters
    year = Year.create!(
      first_trimester: create_trimester(Date.new(2024,8,1), Date.new(2024,10,31)),
      second_trimester: create_trimester(Date.new(2024,11,1), Date.new(2025,1,31)),
      third_trimester: create_trimester(Date.new(2025,2,1), Date.new(2025,4,30)),
      fourth_trimester: create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
    )
    
    # Create a school class with the year
    school_class = SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: year,
      teacher: teacher
    )
    
    sign_in dean
    
    assert_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: subject.id,
          teacher_id: teacher.id,
          school_class_id: school_class.id,
          trimester_ids: [year.first_trimester.id]
        }
      }
    end

    assert_redirected_to lecture_url(Lecture.last)
  end
  
  test "should not create lecture when signed in as teacher" do
    teacher = create_teacher
    subject = create_subject
    trimester = create_trimester
    sign_in teacher
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: subject.id,
          trimester_ids: [trimester.id]
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not create lecture when signed in as student" do
    student = create_student
    subject = create_subject
    trimester = create_trimester
    sign_in student
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: subject.id,
          trimester_ids: [trimester.id]
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not create lecture with invalid data" do
    dean = create_dean
    subject = create_subject
    trimester = create_trimester
    sign_in dean
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "10:00",
          end_time: "09:00", # Invalid: end time before start time
          week_day: "monday",
          subject_id: subject.id,
          trimester_ids: [trimester.id]
        }
      }
    end
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this lecture from being saved/
  end
  
  # EDIT TESTS
  
  test "should get edit when signed in as dean" do
    dean = create_dean
    lecture = create_lecture
    sign_in dean
    get edit_lecture_url(lecture)
    assert_response :success
    assert_select "h1", "Editing lecture"
  end
  
  test "should not get edit when signed in as teacher" do
    teacher = create_teacher
    lecture = create_lecture
    sign_in teacher
    get edit_lecture_url(lecture)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get edit when signed in as student" do
    student = create_student
    lecture = create_lecture
    sign_in student
    get edit_lecture_url(lecture)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # UPDATE TESTS
  
  test "should update lecture when signed in as dean" do
    dean = create_dean
    lecture = create_lecture
    sign_in dean
    
    # Get the year from the lecture's school class
    year = lecture.school_class.year
    
    patch lecture_url(lecture), params: {
      lecture: {
        start_time: "10:00",
        end_time: "11:30",
        week_day: "tuesday",
        trimester_ids: [year.second_trimester.id]  # Use a different trimester from the same year
      }
    }
    
    assert_redirected_to lecture_url(lecture)
    lecture.reload
    assert_equal "10:00", lecture.start_time.strftime("%H:%M")
    assert_equal "tuesday", lecture.week_day
    assert_includes lecture.trimesters, year.second_trimester
  end
  
  test "should not update lecture when signed in as teacher" do
    teacher = create_teacher
    lecture = create_lecture
    original_start_time = lecture.start_time
    original_trimester_ids = lecture.trimester_ids
    sign_in teacher
    
    patch lecture_url(lecture), params: {
      lecture: {
        start_time: "11:00",
        trimester_ids: [create_trimester.id]
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    lecture.reload
    assert_equal original_start_time, lecture.start_time
    assert_equal original_trimester_ids, lecture.trimester_ids
  end
  
  test "should not update lecture when signed in as student" do
    student = create_student
    lecture = create_lecture
    original_start_time = lecture.start_time
    original_trimester_ids = lecture.trimester_ids
    sign_in student
    
    patch lecture_url(lecture), params: {
      lecture: {
        start_time: "11:00",
        trimester_ids: [create_trimester.id]
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    lecture.reload
    assert_equal original_start_time, lecture.start_time
    assert_equal original_trimester_ids, lecture.trimester_ids
  end
  
  test "should not update lecture with invalid data" do
    dean = create_dean
    lecture = create_lecture
    original_start_time = lecture.start_time
    original_end_time = lecture.end_time
    sign_in dean
    
    patch lecture_url(lecture), params: {
      lecture: {
        start_time: "10:00",
        end_time: "09:00", # Invalid: end time before start time
      }
    }
    
    assert_response :unprocessable_entity
    
    # Verify nothing changed
    lecture.reload
    assert_equal original_start_time, lecture.start_time
    assert_equal original_end_time, lecture.end_time
  end
  
  # DELETE TESTS
  
  test "should destroy lecture when signed in as dean" do
    dean = create_dean
    lecture = create_lecture
    sign_in dean
    
    assert_difference("Lecture.count", -1) do
      delete lecture_url(lecture)
    end
    
    assert_redirected_to lectures_url
    assert_equal "Lecture was successfully destroyed.", flash[:notice]
  end
  
  test "should not destroy lecture when signed in as teacher" do
    teacher = create_teacher
    lecture = create_lecture
    sign_in teacher
    
    assert_no_difference("Lecture.count") do
      delete lecture_url(lecture)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not destroy lecture when signed in as student" do
    student = create_student
    lecture = create_lecture
    sign_in student
    
    assert_no_difference("Lecture.count") do
      delete lecture_url(lecture)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  # TEACHER-SUBJECT VALIDATION TESTS
  
  test "should not create lecture with teacher who doesn't teach the subject" do
    dean = create_dean
    subject = create_subject
    teacher = create_teacher
    # Deliberately NOT associating the teacher with the subject
    trimester = create_trimester
    sign_in dean
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: subject.id,
          teacher_id: teacher.id,
          trimester_ids: [trimester.id]
        }
      }
    end
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this lecture from being saved/
    assert_select "li", "Teacher must teach this subject"
  end

  test "should not update lecture to assign teacher who doesn't teach the subject" do
    dean = create_dean
    lecture = create_lecture
    new_teacher = create_teacher  # This teacher doesn't teach the subject
    sign_in dean
    
    # Store original values
    original_teacher_id = lecture.teacher_id
    original_subject_id = lecture.subject_id
    
    patch lecture_url(lecture), params: {
      lecture: {
        teacher_id: new_teacher.id,
        trimester_ids: [lecture.school_class.year.first_trimester.id]  # Use the same year's trimester
      }
    }
    
    # Expect a redirect back to the lecture URL
    assert_redirected_to lecture_url(lecture)
    
    # Verify nothing changed
    lecture.reload
    assert_equal original_teacher_id, lecture.teacher_id
    assert_equal original_subject_id, lecture.subject_id
  end

  test "should update lecture with new teacher who teaches the subject" do
    dean = create_dean
    lecture = create_lecture
    new_teacher = create_teacher
    sign_in dean  # Make sure we're signed in before any modifications
    
    # Clear any existing associations and create a new one
    lecture.subject.teachers.clear
    lecture.subject.teachers << new_teacher
    
    # Use a trimester from the same year
    year = lecture.school_class.year
    
    patch lecture_url(lecture), params: {
      lecture: {
        teacher_id: new_teacher.id,
        trimester_ids: [year.second_trimester.id]
      }
    }
    
    assert_redirected_to lecture_url(lecture)
    lecture.reload
    assert_equal new_teacher.id, lecture.teacher_id
    assert_includes lecture.trimesters, year.second_trimester
  end
end
