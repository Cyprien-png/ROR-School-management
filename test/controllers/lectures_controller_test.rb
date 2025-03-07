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
    trimester = create_trimester
    sign_in dean
    
    assert_difference("Lecture.count") do
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
    
    lecture = Lecture.last
    assert_redirected_to lecture_url(lecture)
    assert_equal "Lecture was successfully created.", flash[:notice]
    assert_equal "09:00", lecture.start_time.strftime("%H:%M")
    assert_equal "10:30", lecture.end_time.strftime("%H:%M")
    assert_equal "monday", lecture.week_day
    assert_equal subject.id, lecture.subject_id
    assert_equal [trimester.id], lecture.trimester_ids
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
    new_subject = Subject.create!(name: "New Subject #{@timestamp}")
    new_trimester = create_trimester(Date.new(2024,11,1), Date.new(2025,1,31))
    sign_in dean
    
    patch lecture_url(lecture), params: {
      lecture: {
        start_time: "11:00",
        end_time: "12:30",
        week_day: "tuesday",
        subject_id: new_subject.id,
        trimester_ids: [new_trimester.id]
      }
    }
    
    lecture.reload
    assert_redirected_to lecture_url(lecture)
    assert_equal "Lecture was successfully updated.", flash[:notice]
    assert_equal "11:00", lecture.start_time.strftime("%H:%M")
    assert_equal "12:30", lecture.end_time.strftime("%H:%M")
    assert_equal "tuesday", lecture.week_day
    assert_equal new_subject.id, lecture.subject_id
    assert_equal [new_trimester.id], lecture.trimester_ids
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
    original_trimester_ids = lecture.trimester_ids
    sign_in dean
    
    patch lecture_url(lecture), params: {
      lecture: {
        start_time: "10:00",
        end_time: "09:00", # Invalid: end time before start time
        trimester_ids: [create_trimester.id]
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this lecture from being saved/
    lecture.reload
    assert_equal original_trimester_ids, lecture.trimester_ids
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
end
