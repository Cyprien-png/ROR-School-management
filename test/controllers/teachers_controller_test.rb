require "test_helper"

class TeachersControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @timestamp = Time.current.to_f
  end

  def create_dean
    Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )
  end

  def create_teacher
    Teacher.create!(
      lastname: "Smith",
      firstname: "John",
      email: "teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "9876543210",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
  end

  def create_student
    Student.create!(
      lastname: "Doe",
      firstname: "Jane",
      email: "student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "5555555555",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
  end

  test "should get new when dean" do
    dean = create_dean
    sign_in dean
    get new_teacher_url
    assert_response :success
    assert_select "h1", "New Teacher"
  end

  test "should not get new when teacher" do
    teacher = create_teacher
    sign_in teacher
    get new_teacher_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get new when student" do
    student = create_student
    sign_in student
    get new_teacher_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create teacher when dean" do
    dean = create_dean
    sign_in dean
    
    assert_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "New",
          firstname: "Teacher",
          email: "new.teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
          phone_number: "1111111111",
          iban: "GB29NWBK60161331926819",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    teacher = Teacher.last
    assert_redirected_to person_url(teacher)
    assert_equal "Teacher was successfully created.", flash[:notice]
    assert_equal "New", teacher.lastname
    assert_equal "Teacher", teacher.firstname
  end

  test "should not create teacher when teacher" do
    teacher = create_teacher
    sign_in teacher
    
    assert_no_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "New",
          firstname: "Teacher",
          email: "new.teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
          phone_number: "1111111111",
          iban: "GB29NWBK60161331926819",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not create teacher when student" do
    student = create_student
    sign_in student
    
    assert_no_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "New",
          firstname: "Teacher",
          email: "new.teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
          phone_number: "1111111111",
          iban: "GB29NWBK60161331926819",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not create teacher with invalid data" do
    dean = create_dean
    sign_in dean
    
    assert_no_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "", # Invalid: blank lastname
          firstname: "Teacher",
          email: "invalid-email", # Invalid email format
          phone_number: "1111111111",
          iban: "", # Invalid: blank IBAN
          password: "password",
          password_confirmation: "different_password" # Invalid: doesn't match password
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this teacher from being saved/
  end

  test "should get edit when dean" do
    dean = create_dean
    teacher = create_teacher
    sign_in dean
    get edit_teacher_url(teacher)
    assert_response :success
    assert_select "h1", "Editing teacher"
  end

  test "should not get edit when teacher" do
    teacher = create_teacher
    sign_in teacher
    get edit_teacher_url(teacher)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get edit when student" do
    student = create_student
    teacher = create_teacher
    sign_in student
    get edit_teacher_url(teacher)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update teacher when dean" do
    dean = create_dean
    teacher = create_teacher
    sign_in dean
    
    patch teacher_url(teacher), params: {
      teacher: {
        lastname: "Updated",
        firstname: "Name",
        email: "updated.teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
        phone_number: "9999999999",
        iban: "GB29NWBK60161331926820"
      }
    }
    
    teacher.reload
    assert_redirected_to person_url(teacher)
    assert_equal "Teacher was successfully updated.", flash[:notice]
    assert_equal "Updated", teacher.lastname
    assert_equal "Name", teacher.firstname
    assert_equal "GB29NWBK60161331926820", teacher.iban
  end

  test "should not update teacher when teacher" do
    teacher = create_teacher
    original_lastname = teacher.lastname
    
    sign_in teacher
    
    patch teacher_url(teacher), params: {
      teacher: {
        lastname: "Updated",
        firstname: "Name"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    teacher.reload
    assert_equal original_lastname, teacher.lastname
  end

  test "should not update teacher when student" do
    student = create_student
    teacher = create_teacher
    original_lastname = teacher.lastname
    
    sign_in student
    
    patch teacher_url(teacher), params: {
      teacher: {
        lastname: "Updated",
        firstname: "Name"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    teacher.reload
    assert_equal original_lastname, teacher.lastname
  end

  test "should soft_delete teacher when dean" do
    dean = create_dean
    teacher = create_teacher
    sign_in dean
    
    # We need to use unscoped count because the default scope excludes soft-deleted records
    assert_difference("Teacher.unscoped.where(isDeleted: true).count", 1) do
      delete teacher_url(teacher)
    end
    
    assert_redirected_to people_url
    assert_equal "Teacher was successfully deleted.", flash[:notice]
    
    # Verify the teacher is soft deleted
    teacher.reload
    assert teacher.isDeleted
    
    # Verify the teacher is not returned in normal queries
    assert_not Teacher.exists?(teacher.id)
    assert Teacher.with_deleted.exists?(teacher.id)
  end

  test "should not delete teacher when teacher" do
    teacher = create_teacher
    sign_in teacher
    
    assert_no_difference("Teacher.count") do
      delete teacher_url(teacher)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the teacher is not deleted
    teacher.reload
    assert_not teacher.isDeleted
  end

  test "should not delete teacher when student" do
    student = create_student
    teacher = create_teacher
    sign_in student
    
    assert_no_difference("Teacher.count") do
      delete teacher_url(teacher)
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the teacher is not deleted
    teacher.reload
    assert_not teacher.isDeleted
  end
end 