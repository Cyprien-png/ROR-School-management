require "test_helper"

class SubjectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    @subject = create_subject
    
    # Create a school class for the teacher to fix layout issues
    @school_class = create_school_class(@teacher)
  end

  # INDEX TESTS
  
  test "should get index when signed in as dean" do
    sign_in @dean
    get subjects_url
    assert_response :success
    assert_select "h1", "Academic Subjects"
  end
  
  test "should get index when signed in as teacher" do
    sign_in @teacher
    get subjects_url
    assert_response :success
    assert_select "h1", "Academic Subjects"
  end
  
  test "should get index when signed in as student" do
    sign_in @student
    get subjects_url
    assert_response :success
    assert_select "h1", "Academic Subjects"
  end
  
  test "should redirect index when not signed in" do
    get subjects_url
    assert_redirected_to new_person_session_path
  end
  
  # SHOW TESTS
  
  test "should show subject when signed in as dean" do
    sign_in @dean
    get subject_url(@subject)
    assert_response :success
  end
  
  test "should show subject when signed in as teacher" do
    sign_in @teacher
    get subject_url(@subject)
    assert_response :success
  end
  
  test "should show subject when signed in as student" do
    sign_in @student
    get subject_url(@subject)
    assert_response :success
  end
  
  test "should redirect show when not signed in" do
    get subject_url(@subject)
    assert_redirected_to new_person_session_path
  end
  
  # NEW TESTS
  
  test "should get new when signed in as dean" do
    sign_in @dean
    get new_subject_url
    assert_response :success
    assert_select "h1", "New Subject"
  end
  
  test "should not get new when signed in as teacher" do
    sign_in @teacher
    get new_subject_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get new when signed in as student" do
    sign_in @student
    get new_subject_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # CREATE TESTS
  
  test "should create subject when signed in as dean" do
    sign_in @dean
    
    assert_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: "New Subject #{@timestamp}"
        }
      }
    end
    
    subject = Subject.last
    assert_redirected_to subject_url(subject)
    assert_equal "Subject was successfully created.", flash[:notice]
    assert_equal "New Subject #{@timestamp}", subject.name
  end
  
  test "should not create subject when signed in as teacher" do
    sign_in @teacher
    
    assert_no_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: "New Subject #{@timestamp}"
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not create subject when signed in as student" do
    sign_in @student
    
    assert_no_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: "New Subject #{@timestamp}"
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not create subject with invalid data" do
    sign_in @dean
    assert_no_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: ""
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this subject from being saved/
  end
  
  test "should not create subject with duplicate name" do
    sign_in @dean
    # Create a subject with the same name
    Subject.create!(name: "Duplicate Subject")
    
    assert_no_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: "Duplicate Subject"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this subject from being saved/
  end
  
  # EDIT TESTS
  
  test "should get edit when signed in as dean" do
    sign_in @dean
    get edit_subject_url(@subject)
    assert_response :success
    assert_select "h1", /Edit Subject: .*/
  end
  
  test "should not get edit when signed in as teacher" do
    sign_in @teacher
    get edit_subject_url(@subject)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get edit when signed in as student" do
    sign_in @student
    get edit_subject_url(@subject)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # UPDATE TESTS
  
  test "should update subject when signed in as dean" do
    sign_in @dean
    
    patch subject_url(@subject), params: {
      subject: {
        name: "Updated Subject #{@timestamp}"
      }
    }
    
    @subject.reload
    assert_redirected_to subject_url(@subject)
    assert_equal "Subject was successfully updated.", flash[:notice]
    assert_equal "Updated Subject #{@timestamp}", @subject.name
  end
  
  test "should not update subject when signed in as teacher" do
    sign_in @teacher
    original_name = @subject.name
    
    patch subject_url(@subject), params: {
      subject: {
        name: "Updated Subject #{@timestamp}"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    @subject.reload
    assert_equal original_name, @subject.name
  end
  
  test "should not update subject when signed in as student" do
    sign_in @student
    original_name = @subject.name
    
    patch subject_url(@subject), params: {
      subject: {
        name: "Updated Subject #{@timestamp}"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    @subject.reload
    assert_equal original_name, @subject.name
  end
  
  test "should not update subject with invalid data" do
    sign_in @dean
    patch subject_url(@subject), params: {
      subject: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this subject from being saved/
  end
  
  # DELETE TESTS
  
  test "should soft delete subject when signed in as dean" do
    sign_in @dean
    
    assert_no_difference("Subject.with_deleted.count") do
      delete subject_url(@subject)
    end
    
    assert_redirected_to subjects_url
    assert_equal "Subject was successfully deleted.", flash[:notice]
    
    # Verify the subject is soft deleted
    @subject.reload
    assert @subject.isDeleted?
    assert_not Subject.exists?(@subject.id)
    assert Subject.with_deleted.exists?(@subject.id)
  end
  
  test "should not delete subject when signed in as teacher" do
    sign_in @teacher
    
    assert_no_difference("Subject.count") do
      delete subject_url(@subject)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the subject is not deleted
    @subject.reload
    assert_not @subject.isDeleted
  end
  
  test "should not delete subject when signed in as student" do
    sign_in @student
    
    assert_no_difference("Subject.count") do
      delete subject_url(@subject)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the subject is not deleted
    @subject.reload
    assert_not @subject.isDeleted
  end
  
  # TEACHER ASSIGNMENT TESTS
  
  test "should assign teachers to subject when signed in as dean" do
    sign_in @dean
    teacher1 = Teacher.create!(
      lastname: "Doe",
      firstname: "Jane",
      email: "teacher2-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "5555555555",
      iban: "GB29NWBK60161331926820",
      password: "password",
      password_confirmation: "password"
    )
    
    assert_difference -> { @subject.teachers.count }, 2 do
      patch subject_url(@subject), params: {
        subject: {
          name: @subject.name,
          teacher_ids: [teacher1.id, @teacher.id]
        }
      }
    end
    
    assert_redirected_to subject_url(@subject)
    assert_equal "Subject was successfully updated.", flash[:notice]
    assert_includes @subject.teachers, teacher1
    assert_includes @subject.teachers, @teacher
  end
end
