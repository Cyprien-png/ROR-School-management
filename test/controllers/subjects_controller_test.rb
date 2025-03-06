require "test_helper"

class SubjectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
  end

  # INDEX TESTS
  
  test "should get index when signed in as dean" do
    dean = create_dean
    sign_in dean
    get subjects_url
    assert_response :success
    assert_select "h1", "Subjects"
  end
  
  test "should get index when signed in as teacher" do
    teacher = create_teacher
    sign_in teacher
    get subjects_url
    assert_response :success
    assert_select "h1", "Subjects"
  end
  
  test "should get index when signed in as student" do
    student = create_student
    sign_in student
    get subjects_url
    assert_response :success
    assert_select "h1", "Subjects"
  end
  
  test "should redirect index when not signed in" do
    get subjects_url
    assert_redirected_to new_person_session_path
  end
  
  # SHOW TESTS
  
  test "should show subject when signed in as dean" do
    dean = create_dean
    subject = create_subject
    sign_in dean
    get subject_url(subject)
    assert_response :success
  end
  
  test "should show subject when signed in as teacher" do
    teacher = create_teacher
    subject = create_subject
    sign_in teacher
    get subject_url(subject)
    assert_response :success
  end
  
  test "should show subject when signed in as student" do
    student = create_student
    subject = create_subject
    sign_in student
    get subject_url(subject)
    assert_response :success
  end
  
  test "should redirect show when not signed in" do
    subject = create_subject
    get subject_url(subject)
    assert_redirected_to new_person_session_path
  end
  
  # NEW TESTS
  
  test "should get new when signed in as dean" do
    dean = create_dean
    sign_in dean
    get new_subject_url
    assert_response :success
    assert_select "h1", "New subject"
  end
  
  test "should not get new when signed in as teacher" do
    teacher = create_teacher
    sign_in teacher
    get new_subject_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get new when signed in as student" do
    student = create_student
    sign_in student
    get new_subject_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # CREATE TESTS
  
  test "should create subject when signed in as dean" do
    dean = create_dean
    sign_in dean
    
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
    teacher = create_teacher
    sign_in teacher
    
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
    student = create_student
    sign_in student
    
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
    dean = create_dean
    sign_in dean
    
    assert_no_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: "" # Invalid: blank name
        }
      }
    end
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this subject from being saved/
  end
  
  test "should not create subject with duplicate name" do
    dean = create_dean
    existing_subject = create_subject
    sign_in dean
    
    assert_no_difference("Subject.count") do
      post subjects_url, params: {
        subject: {
          name: existing_subject.name
        }
      }
    end
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this subject from being saved/
  end
  
  # EDIT TESTS
  
  test "should get edit when signed in as dean" do
    dean = create_dean
    subject = create_subject
    sign_in dean
    get edit_subject_url(subject)
    assert_response :success
    assert_select "h1", "Editing subject"
  end
  
  test "should not get edit when signed in as teacher" do
    teacher = create_teacher
    subject = create_subject
    sign_in teacher
    get edit_subject_url(subject)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  test "should not get edit when signed in as student" do
    student = create_student
    subject = create_subject
    sign_in student
    get edit_subject_url(subject)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
  
  # UPDATE TESTS
  
  test "should update subject when signed in as dean" do
    dean = create_dean
    subject = create_subject
    sign_in dean
    
    patch subject_url(subject), params: {
      subject: {
        name: "Updated Subject #{@timestamp}"
      }
    }
    
    subject.reload
    assert_redirected_to subject_url(subject)
    assert_equal "Subject was successfully updated.", flash[:notice]
    assert_equal "Updated Subject #{@timestamp}", subject.name
  end
  
  test "should not update subject when signed in as teacher" do
    teacher = create_teacher
    subject = create_subject
    original_name = subject.name
    sign_in teacher
    
    patch subject_url(subject), params: {
      subject: {
        name: "Updated Subject #{@timestamp}"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    subject.reload
    assert_equal original_name, subject.name
  end
  
  test "should not update subject when signed in as student" do
    student = create_student
    subject = create_subject
    original_name = subject.name
    sign_in student
    
    patch subject_url(subject), params: {
      subject: {
        name: "Updated Subject #{@timestamp}"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    subject.reload
    assert_equal original_name, subject.name
  end
  
  test "should not update subject with invalid data" do
    dean = create_dean
    subject = create_subject
    sign_in dean
    
    patch subject_url(subject), params: {
      subject: {
        name: "" # Invalid: blank name
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this subject from being saved/
  end
  
  # DELETE TESTS
  
  test "should soft delete subject when signed in as dean" do
    dean = create_dean
    subject = create_subject
    sign_in dean
    
    assert_difference("Subject.unscoped.where(isDeleted: true).count", 1) do
      delete subject_url(subject)
    end
    
    assert_redirected_to subjects_url
    assert_equal "Subject was successfully deleted.", flash[:notice]
    
    # Verify the subject is soft deleted
    subject.reload
    assert subject.isDeleted
    
    # Verify the subject is not returned in normal queries
    assert_not Subject.exists?(subject.id)
    assert Subject.with_deleted.exists?(subject.id)
  end
  
  test "should not delete subject when signed in as teacher" do
    teacher = create_teacher
    subject = create_subject
    sign_in teacher
    
    assert_no_difference("Subject.count") do
      delete subject_url(subject)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the subject is not deleted
    subject.reload
    assert_not subject.isDeleted
  end
  
  test "should not delete subject when signed in as student" do
    student = create_student
    subject = create_subject
    sign_in student
    
    assert_no_difference("Subject.count") do
      delete subject_url(subject)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the subject is not deleted
    subject.reload
    assert_not subject.isDeleted
  end
  
  # TEACHER ASSIGNMENT TESTS
  
  test "should assign teachers to subject when signed in as dean" do
    dean = create_dean
    subject = create_subject
    teacher1 = create_teacher
    teacher2 = Teacher.create!(
      lastname: "Johnson",
      firstname: "Mary",
      email: "mary.johnson-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "5551234567",
      iban: "GB29NWBK60161331926820",
      password: "password",
      password_confirmation: "password"
    )
    
    sign_in dean
    
    patch subject_url(subject), params: {
      subject: {
        teacher_ids: [teacher1.id, teacher2.id]
      }
    }
    
    subject.reload
    assert_redirected_to subject_url(subject)
    assert_equal "Subject was successfully updated.", flash[:notice]
    assert_equal 2, subject.teachers.count
    assert subject.teachers.include?(teacher1)
    assert subject.teachers.include?(teacher2)
  end
end
