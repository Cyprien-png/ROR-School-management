require "test_helper"

class SchoolClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create and sign in a dean for authentication
    @dean = Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )
    
    # Sign in the dean
    post person_session_path, params: { 
      person: { 
        email: @dean.email, 
        password: "password" 
      } 
    }

    # Create a teacher for the school class
    @teacher = Teacher.create!(
      lastname: "Smith",
      firstname: "John",
      email: "john.smith@test.com",
      phone_number: "9876543210",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )

    # Create a test school class
    @school_class = SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: 2025,
      teacher: @teacher
    )
  end

  teardown do
    SchoolClass.delete_all
    Person.delete_all
  end

  test "should get index" do
    get school_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_school_class_url
    assert_response :success
  end

  test "should create school_class" do
    assert_difference("SchoolClass.count") do
      post school_classes_url, params: { 
        school_class: { 
          name: "New Class",
          grade: 2,
          year: 2025,
          teacher_id: @teacher.id
        } 
      }
    end

    assert_redirected_to school_class_url(SchoolClass.last)
  end

  test "should show school_class" do
    get school_class_url(@school_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_school_class_url(@school_class)
    assert_response :success
  end

  test "should update school_class" do
    patch school_class_url(@school_class), params: { 
      school_class: { 
        name: "Updated Class",
        grade: 3,
        year: 2026,
        teacher_id: @teacher.id
      } 
    }
    assert_redirected_to school_class_url(@school_class)
  end

  test "should destroy school_class" do
    assert_difference("SchoolClass.count", -1) do
      delete school_class_url(@school_class)
    end

    assert_redirected_to school_classes_url
  end
end
