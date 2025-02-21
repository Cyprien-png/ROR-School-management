require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Create a dean for testing
    @dean = Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )

    # Create a teacher for testing unauthorized access
    @teacher = Teacher.create!(
      lastname: "Smith",
      firstname: "John",
      email: "john.smith@test.com",
      phone_number: "9876543210",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )

    # Create a student for testing unauthorized access
    @student = Student.create!(
      lastname: "Doe",
      firstname: "Jane",
      email: "jane.doe@test.com",
      phone_number: "5555555555",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
  end

  teardown do
    Person.delete_all
  end

  test "should get new when dean" do
    sign_in_as(@dean)
    get new_student_url
    assert_response :success
    assert_select "h1", "New Student"
  end

  test "should not get new when teacher" do
    sign_in_as(@teacher)
    get new_student_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get new when student" do
    sign_in_as(@student)
    get new_student_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create student when dean" do
    sign_in_as(@dean)
    assert_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "New",
          firstname: "Student",
          email: "new.student@test.com",
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
    sign_in_as(@teacher)
    assert_no_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "New",
          firstname: "Student",
          email: "new.student@test.com",
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
    sign_in_as(@student)
    assert_no_difference("Student.count") do
      post students_url, params: {
        student: {
          lastname: "New",
          firstname: "Student",
          email: "new.student@test.com",
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
    sign_in_as(@dean)
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
end 