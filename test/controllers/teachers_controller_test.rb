require "test_helper"

class TeachersControllerTest < ActionDispatch::IntegrationTest
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

    # Create a teacher for testing unauthorized access and editing
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
    get new_teacher_url
    assert_response :success
    assert_select "h1", "New Teacher"
  end

  test "should not get new when teacher" do
    sign_in_as(@teacher)
    get new_teacher_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get new when student" do
    sign_in_as(@student)
    get new_teacher_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create teacher when dean" do
    sign_in_as(@dean)
    assert_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "New",
          firstname: "Teacher",
          email: "new.teacher@test.com",
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
    assert_equal "GB29NWBK60161331926819", teacher.iban
  end

  test "should not create teacher when teacher" do
    sign_in_as(@teacher)
    assert_no_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "New",
          firstname: "Teacher",
          email: "new.teacher@test.com",
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
    sign_in_as(@student)
    assert_no_difference("Teacher.count") do
      post teachers_url, params: {
        teacher: {
          lastname: "New",
          firstname: "Teacher",
          email: "new.teacher@test.com",
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
    sign_in_as(@dean)
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
    sign_in_as(@dean)
    get edit_teacher_url(@teacher)
    assert_response :success
    assert_select "h1", "Editing teacher"
  end

  test "should not get edit when teacher" do
    sign_in_as(@teacher)
    get edit_teacher_url(@teacher)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get edit when student" do
    sign_in_as(@student)
    get edit_teacher_url(@teacher)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update teacher when dean" do
    sign_in_as(@dean)
    patch teacher_url(@teacher), params: {
      teacher: {
        lastname: "Updated",
        firstname: "Name",
        email: "updated.teacher@test.com",
        phone_number: "9999999999",
        iban: "GB29NWBK60161331926820"
      }
    }
    
    @teacher.reload
    assert_redirected_to person_url(@teacher)
    assert_equal "Teacher was successfully updated.", flash[:notice]
    assert_equal "Updated", @teacher.lastname
    assert_equal "Name", @teacher.firstname
    assert_equal "GB29NWBK60161331926820", @teacher.iban
  end
end 