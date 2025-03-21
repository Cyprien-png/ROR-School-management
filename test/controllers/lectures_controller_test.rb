require "test_helper"

class LecturesControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    @subject = create_subject
    @teacher.subjects << @subject
    @year = create_year
    @school_class = create_school_class(@teacher, @year)
    @lecture = create_lecture(@subject, @teacher, @school_class)
  end

  # INDEX TESTS
  
  test "should get index when signed in as dean" do
    sign_in @dean
    get lectures_url
    assert_response :success
    assert_select "h1", "Lectures Schedule"
  end
  
  test "should get index when signed in as teacher" do
    sign_in @teacher
    get lectures_url
    assert_response :success
    assert_select "h1", "Lectures Schedule"
  end
  
  test "should get index when signed in as student" do
    sign_in @student
    get lectures_url
    assert_response :success
    assert_select "h1", "Lectures Schedule"
  end
  
  test "should redirect index when not signed in" do
    get lectures_url
    assert_redirected_to new_person_session_path
  end
  
  # SHOW TESTS
  
  test "should show lecture when signed in as dean" do
    sign_in @dean
    get lecture_url(@lecture)
    assert_response :success
  end
  
  test "should show lecture when signed in as teacher" do
    sign_in @teacher
    get lecture_url(@lecture)
    assert_response :success
  end
  
  test "should show lecture when signed in as student" do
    sign_in @student
    get lecture_url(@lecture)
    assert_response :success
  end
  
  test "should redirect show when not signed in" do
    get lecture_url(@lecture)
    assert_redirected_to new_person_session_path
  end
  
  # NEW TESTS
  
  test "should get new when signed in as dean" do
    sign_in @dean
    get new_lecture_url
    assert_response :success
    assert_select "h1", "New Lecture"
  end
  
  test "should not get new when signed in as teacher" do
    sign_in @teacher
    get new_lecture_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get new when signed in as student" do
    sign_in @student
    get new_lecture_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # CREATE TESTS
  
  test "should create lecture when signed in as dean" do
    sign_in @dean
    
    assert_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: @subject.id,
          teacher_id: @teacher.id,
          school_class_id: @school_class.id,
          trimester_ids: [@year.first_trimester.id]
        }
      }
    end

    assert_redirected_to lecture_url(Lecture.last)
  end
  
  test "should not create lecture when signed in as teacher" do
    sign_in @teacher
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: @subject.id,
          trimester_ids: [create_trimester.id]
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not create lecture when signed in as student" do
    sign_in @student
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "09:00",
          end_time: "10:30",
          week_day: "monday",
          subject_id: @subject.id,
          trimester_ids: [create_trimester.id]
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not create lecture with invalid data" do
    sign_in @dean
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "",
          end_time: "",
          week_day: "",
          subject_id: @subject.id,
          teacher_id: @teacher.id,
          school_class_id: @school_class.id,
          trimester_ids: [@year.first_trimester.id]
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this lecture from being saved/
  end
  
  # EDIT TESTS
  
  test "should get edit when signed in as dean" do
    sign_in @dean
    get edit_lecture_url(@lecture)
    assert_response :success
    assert_select "h1", "Edit Lecture"
  end
  
  test "should not get edit when signed in as teacher" do
    sign_in @teacher
    get edit_lecture_url(@lecture)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get edit when signed in as student" do
    sign_in @student
    get edit_lecture_url(@lecture)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # UPDATE TESTS
  
  test "should update lecture when signed in as dean" do
    sign_in @dean
    
    # Get the year from the lecture's school class
    year = @lecture.school_class.year
    
    patch lecture_url(@lecture), params: {
      lecture: {
        start_time: "10:00",
        end_time: "11:30",
        week_day: "tuesday",
        trimester_ids: [year.second_trimester.id]  # Use a different trimester from the same year
      }
    }
    
    assert_redirected_to lecture_url(@lecture)
    @lecture.reload
    assert_equal "10:00", @lecture.start_time.strftime("%H:%M")
    assert_equal "tuesday", @lecture.week_day
    assert_includes @lecture.trimesters, year.second_trimester
  end
  
  test "should not update lecture when signed in as teacher" do
    sign_in @teacher
    original_start_time = @lecture.start_time
    original_trimester_ids = @lecture.trimester_ids
    
    patch lecture_url(@lecture), params: {
      lecture: {
        start_time: "11:00",
        trimester_ids: [create_trimester.id]
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    @lecture.reload
    assert_equal original_start_time, @lecture.start_time
    assert_equal original_trimester_ids, @lecture.trimester_ids
  end
  
  test "should not update lecture when signed in as student" do
    sign_in @student
    original_start_time = @lecture.start_time
    original_trimester_ids = @lecture.trimester_ids
    
    patch lecture_url(@lecture), params: {
      lecture: {
        start_time: "11:00",
        trimester_ids: [create_trimester.id]
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    @lecture.reload
    assert_equal original_start_time, @lecture.start_time
    assert_equal original_trimester_ids, @lecture.trimester_ids
  end
  
  test "should not update lecture with invalid data" do
    sign_in @dean
    original_start_time = @lecture.start_time
    original_end_time = @lecture.end_time
    
    patch lecture_url(@lecture), params: {
      lecture: {
        start_time: "10:00",
        end_time: "09:00", # Invalid: end time before start time
      }
    }
    
    assert_response :unprocessable_entity
    
    # Verify nothing changed
    @lecture.reload
    assert_equal original_start_time, @lecture.start_time
    assert_equal original_end_time, @lecture.end_time
  end
  
  # DELETE TESTS
  
  test "should destroy lecture when signed in as dean" do
    sign_in @dean
    
    assert_no_difference("Lecture.with_deleted.count") do
      delete lecture_url(@lecture)
    end
    
    assert_redirected_to lectures_url
    assert_equal "Lecture was successfully deleted.", flash[:notice]
    
    # Verify the lecture is soft deleted
    @lecture.reload
    assert @lecture.isDeleted
    
    # Verify the lecture is not returned in normal queries
    assert_not Lecture.exists?(@lecture.id)
    assert Lecture.with_deleted.exists?(@lecture.id)
  end
  
  test "should not destroy lecture when signed in as teacher" do
    sign_in @teacher
    
    assert_no_difference("Lecture.with_deleted.count") do
      delete lecture_url(@lecture)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the lecture is not deleted
    @lecture.reload
    assert_not @lecture.isDeleted
  end
  
  test "should not destroy lecture when signed in as student" do
    sign_in @student
    
    assert_no_difference("Lecture.with_deleted.count") do
      delete lecture_url(@lecture)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the lecture is not deleted
    @lecture.reload
    assert_not @lecture.isDeleted
  end

  # DELETED LECTURES TESTS

  test "should show deleted lectures when signed in as dean" do
    sign_in @dean
    
    # Delete a lecture first
    @lecture.soft_delete
    
    get deleted_lectures_url
    assert_response :success
    assert_select "h1", "Deleted Lectures"
    
    # Verify the deleted lecture appears in the list
    assert_select "td", @lecture.subject.name
    assert_select "td", @lecture.school_class.name
  end

  test "should restore deleted lecture when signed in as dean" do
    sign_in @dean
    
    # Delete a lecture first
    @lecture.soft_delete
    assert @lecture.reload.isDeleted
    
    patch undelete_lecture_url(@lecture)
    assert_redirected_to lectures_url
    assert_equal "Lecture was successfully restored.", flash[:notice]
    
    # Verify the lecture is restored
    @lecture.reload
    assert_not @lecture.isDeleted
    assert Lecture.exists?(@lecture.id)
  end

  test "should not show deleted lectures when signed in as teacher" do
    sign_in @teacher
    get deleted_lectures_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not show deleted lectures when signed in as student" do
    sign_in @student
    get deleted_lectures_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not restore deleted lecture when signed in as teacher" do
    sign_in @teacher
    
    # Delete a lecture first
    @lecture.soft_delete
    assert @lecture.reload.isDeleted
    
    patch undelete_lecture_url(@lecture)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the lecture is still deleted
    assert @lecture.reload.isDeleted
  end

  test "should not restore deleted lecture when signed in as student" do
    sign_in @student
    
    # Delete a lecture first
    @lecture.soft_delete
    assert @lecture.reload.isDeleted
    
    patch undelete_lecture_url(@lecture)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the lecture is still deleted
    assert @lecture.reload.isDeleted
  end

  # TEACHER-SUBJECT VALIDATION TESTS
  
  test "should not create lecture with teacher who doesn't teach the subject" do
    sign_in @dean
    
    # Create a new teacher who doesn't teach the subject
    other_teacher = Teacher.create!(
      lastname: "Johnson",
      firstname: "Sarah",
      email: "sarah.johnson@example.com",
      phone_number: "5551234567",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
    
    assert_no_difference("Lecture.count") do
      post lectures_url, params: {
        lecture: {
          start_time: "13:00",
          end_time: "14:30",
          week_day: "monday",
          subject_id: @subject.id,
          teacher_id: other_teacher.id,
          school_class_id: @school_class.id,
          trimester_ids: [@year.first_trimester.id]
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this lecture from being saved/
  end

  test "should not update lecture to assign teacher who doesn't teach the subject" do
    sign_in @dean
    new_teacher = create_teacher  # This teacher doesn't teach the subject
    
    # Store original values
    original_teacher_id = @lecture.teacher_id
    original_subject_id = @lecture.subject_id
    
    patch lecture_url(@lecture), params: {
      lecture: {
        teacher_id: new_teacher.id,
        trimester_ids: [@year.first_trimester.id]  # Use the same year's trimester
      }
    }
    
    # Expect a redirect back to the lecture URL
    assert_redirected_to lecture_url(@lecture)
    
    # Verify nothing changed
    @lecture.reload
    assert_equal original_teacher_id, @lecture.teacher_id
    assert_equal original_subject_id, @lecture.subject_id
  end

  test "should update lecture with new teacher who teaches the subject" do
    sign_in @dean
    new_teacher = create_teacher
    
    # Clear any existing associations and create a new one
    @lecture.subject.teachers.clear
    @lecture.subject.teachers << new_teacher
    
    # Use a trimester from the same year
    year = @lecture.school_class.year
    
    patch lecture_url(@lecture), params: {
      lecture: {
        teacher_id: new_teacher.id,
        trimester_ids: [year.second_trimester.id]
      }
    }
    
    assert_redirected_to lecture_url(@lecture)
    @lecture.reload
    assert_equal new_teacher.id, @lecture.teacher_id
    assert_includes @lecture.trimesters, year.second_trimester
  end
end
