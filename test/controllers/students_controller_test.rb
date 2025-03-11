require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @timestamp = Time.current.to_f
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    
    # Create a school class for the teacher to fix layout issues
    @school_class = create_school_class(@teacher)
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
          lastname: "",
          firstname: "",
          email: "invalid",
          phone_number: "",
          status: "",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this student from being saved/
  end

  test "should get edit when dean" do
    dean = create_dean
    student = create_student
    sign_in dean
    get edit_student_url(student)
    assert_response :success
    assert_select "h1", /Edit Student: .*/
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
        lastname: "",
        firstname: "",
        email: "invalid",
        phone_number: "",
        status: ""
      }
    }
    assert_response :unprocessable_entity
    assert_select ".bg-red-50", /prohibited this student from being saved/
  end

  test "should not access grade report if not dean" do
    sign_in @teacher
    get grade_report_student_url(@student)
    assert_redirected_to root_path
    assert_equal "You are not authorized to view this grade report.", flash[:alert]
  end

  test "should access grade report if dean" do
    # Create necessary test data
    dean = create_dean
    student = create_student
    teacher = create_teacher
    year = create_year
    school_class = create_school_class(teacher, year)
    school_class.students << student
    
    # Try accessing as a dean
    sign_in dean
    get grade_report_student_path(student)
    assert_response :success
    assert_select "h1", "Grade Report: #{student.firstname} #{student.lastname}"
  end

  test "should redirect to people path if student has no class" do
    # Create test data
    dean = create_dean
    student = create_student
    
    # Try accessing grade report for student without class
    sign_in dean
    get grade_report_student_path(student)
    assert_redirected_to people_url
    assert_equal "Student is not assigned to any class.", flash[:alert]
  end

  test "should handle year selection in grade report" do
    sign_in @dean
    
    # Create a school class and add the student to it
    school_class = create_school_class
    school_class.students << @student
    
    # Create some grades for the student
    lecture = create_lecture(nil, nil, school_class)
    examination = create_examination(lecture)
    grade = Grade.create!(
      value: 5.0,
      examination: examination,
      student: @student
    )
    
    # Test with year parameter
    get grade_report_student_url(@student, year_id: school_class.year.id)
    assert_response :success
    assert_select ".overflow-hidden", { minimum: 1 }
  end
end 