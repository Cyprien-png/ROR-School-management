require "test_helper"

class SchoolClassesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

    # Create students for testing
    @student = Student.create!(
      lastname: "Doe",
      firstname: "Jane",
      email: "jane.doe@test.com",
      phone_number: "5555555555",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )

    @student2 = Student.create!(
      lastname: "Smith",
      firstname: "John",
      email: "john.student@test.com",
      phone_number: "5555555556",
      status: :in_formation,
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

    # Add student2 to the class initially
    @school_class.students << @student2
  end

  teardown do
    SchoolClass.all.each { |school_class| school_class.students.clear }
    SchoolClass.delete_all
    Person.delete_all
  end

  test "should add student to class when dean" do
    sign_in_as(@dean)
    assert_difference -> { @school_class.students.count }, 1 do
      post add_student_school_class_url(@school_class), params: { student_id: @student.id }
    end
    assert_redirected_to school_class_url(@school_class)
    assert_equal "Student was successfully added to the class.", flash[:notice]
    assert @school_class.students.include?(@student)
  end

  test "should not add student to class when teacher" do
    sign_in_as(@teacher)
    assert_no_difference -> { @school_class.students.count } do
      post add_student_school_class_url(@school_class), params: { student_id: @student.id }
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    assert_not @school_class.students.include?(@student)
  end

  test "should not add student to class when student" do
    sign_in_as(@student)
    assert_no_difference -> { @school_class.students.count } do
      post add_student_school_class_url(@school_class), params: { student_id: @student.id }
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    assert_not @school_class.students.include?(@student)
  end

  test "should remove student from class when dean" do
    sign_in_as(@dean)
    assert_difference -> { @school_class.students.count }, -1 do
      delete remove_student_school_class_url(@school_class), params: { student_id: @student2.id }
    end
    assert_redirected_to school_class_url(@school_class)
    assert_equal "Student was successfully removed from the class.", flash[:notice]
    assert_not @school_class.students.include?(@student2)
  end

  test "should not remove student from class when teacher" do
    sign_in_as(@teacher)
    assert_no_difference -> { @school_class.students.count } do
      delete remove_student_school_class_url(@school_class), params: { student_id: @student2.id }
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    assert @school_class.students.include?(@student2)
  end

  test "should not remove student from class when student" do
    sign_in_as(@student)
    assert_no_difference -> { @school_class.students.count } do
      delete remove_student_school_class_url(@school_class), params: { student_id: @student2.id }
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    assert @school_class.students.include?(@student2)
  end

  test "should get index when signed in as any user type" do
    # Test as dean
    sign_in_as(@dean)
    get school_classes_url
    assert_response :success

    # Test as teacher
    sign_in_as(@teacher)
    get school_classes_url
    assert_response :success

    # Test as student
    sign_in_as(@student)
    get school_classes_url
    assert_response :success
  end

  test "should get new when dean" do
    sign_in_as(@dean)
    get new_school_class_url
    assert_response :success
  end

  test "should not get new when teacher" do
    sign_in_as(@teacher)
    get new_school_class_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get new when student" do
    sign_in_as(@student)
    get new_school_class_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create school_class when dean" do
    sign_in_as(@dean)
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

  test "should not create school_class when teacher" do
    sign_in_as(@teacher)
    assert_no_difference("SchoolClass.count") do
      post school_classes_url, params: {
        school_class: {
          name: "New Class",
          grade: 2,
          year: 2025,
          teacher_id: @teacher.id
        }
      }
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should show school_class for any user type" do
    # Test as dean
    sign_in_as(@dean)
    get school_class_url(@school_class)
    assert_response :success

    # Test as teacher
    sign_in_as(@teacher)
    get school_class_url(@school_class)
    assert_response :success

    # Test as student
    sign_in_as(@student)
    get school_class_url(@school_class)
    assert_response :success
  end

  test "should get edit when dean" do
    sign_in_as(@dean)
    get edit_school_class_url(@school_class)
    assert_response :success
  end

  test "should not get edit when teacher" do
    sign_in_as(@teacher)
    get edit_school_class_url(@school_class)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update school_class when dean" do
    sign_in_as(@dean)
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

  test "should not update school_class when teacher" do
    sign_in_as(@teacher)
    patch school_class_url(@school_class), params: {
      school_class: {
        name: "Updated Class",
        grade: 3,
        year: 2026,
        teacher_id: @teacher.id
      }
    }
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should destroy school_class when dean" do
    sign_in_as(@dean)
    assert_difference("SchoolClass.count", -1) do
      delete school_class_url(@school_class)
    end

    assert_redirected_to school_classes_url
  end

  test "should not destroy school_class when teacher" do
    sign_in_as(@teacher)
    assert_no_difference("SchoolClass.count") do
      delete school_class_url(@school_class)
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
end
