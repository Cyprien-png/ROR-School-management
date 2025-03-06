require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
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
    get new_student_url
    assert_response :success
    assert_select "h1", "New Student"
  end

  test "should not get new when teacher" do
    teacher = create_teacher
    sign_in teacher
    get new_student_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get new when student" do
    student = create_student
    sign_in student
    get new_student_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create student when dean" do
    dean = create_dean
    sign_in dean
    
    assert_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "New",
          firstname: "Student",
          email: "new.student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
          phone_number: "1111111111",
          status: "in_formation",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    student = Student.last
    assert_redirected_to person_url(student)
    assert_equal "Student was successfully created.", flash[:notice]
    assert_equal "New", student.lastname
    assert_equal "Student", student.firstname
    assert_equal "in_formation", student.status
  end

  test "should not create student when teacher" do
    teacher = create_teacher
    sign_in teacher
    
    assert_no_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "New",
          firstname: "Student",
          email: "new.student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
          phone_number: "1111111111",
          status: "in_formation",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not create student when student" do
    student = create_student
    sign_in student
    
    assert_no_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "New",
          firstname: "Student",
          email: "new.student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
          phone_number: "1111111111",
          status: "in_formation",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not create student with invalid data" do
    dean = create_dean
    sign_in dean
    
    assert_no_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "", # Invalid: blank lastname
          firstname: "Student",
          email: "invalid-email", # Invalid email format
          phone_number: "1111111111",
          status: "in_formation",
          password: "password",
          password_confirmation: "different_password" # Invalid: doesn't match password
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this student from being saved/
  end

  test "should get edit when dean" do
    dean = create_dean
    student = create_student
    sign_in dean
    get edit_student_url(student)
    assert_response :success
    assert_select "h1", "Editing student"
  end

  test "should not get edit when teacher" do
    teacher = create_teacher
    student = create_student
    sign_in teacher
    get edit_student_url(student)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get edit when student" do
    current_student = create_student
    other_student = create_student
    sign_in current_student
    get edit_student_url(other_student)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update student when dean" do
    dean = create_dean
    student = create_student
    sign_in dean
    
    patch student_url(student), params: {
      student: {
        lastname: "Updated",
        firstname: "Name",
        email: "updated.student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
        phone_number: "9999999999",
        status: "finished"
      }
    }
    
    student.reload
    assert_redirected_to person_url(student)
    assert_equal "Student was successfully updated.", flash[:notice]
    assert_equal "Updated", student.lastname
    assert_equal "Name", student.firstname
    assert_equal "finished", student.status
  end

  test "should not update student when teacher" do
    teacher = create_teacher
    student = create_student
    original_lastname = student.lastname
    
    sign_in teacher
    
    patch student_url(student), params: {
      student: {
        lastname: "Updated",
        firstname: "Name"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    student.reload
    assert_equal original_lastname, student.lastname
  end

  test "should not update student when student" do
    current_student = create_student
    other_student = create_student
    original_lastname = other_student.lastname
    
    sign_in current_student
    
    patch student_url(other_student), params: {
      student: {
        lastname: "Updated",
        firstname: "Name"
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    other_student.reload
    assert_equal original_lastname, other_student.lastname
  end

  test "should not update student with invalid data" do
    dean = create_dean
    student = create_student
    sign_in dean
    
    patch student_url(student), params: {
      student: {
        lastname: "", # Invalid: blank lastname
        email: "invalid-email" # Invalid email format
      }
    }
    
    assert_response :unprocessable_entity
    assert_select "h2", /prohibited this student from being saved/
  end
end 