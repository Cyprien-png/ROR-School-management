require "test_helper"

class GradesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    super
    @timestamp = Time.current.to_f
    
    # Create users with unique emails
    @dean = Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )

    @teacher = Teacher.create!(
      lastname: "Smith",
      firstname: "John",
      email: "teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "9876543210",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )

    @student = Student.create!(
      lastname: "Doe",
      firstname: "Jane",
      email: "student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "5555555555",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
    
    # Create a year with trimesters
    @year = Year.create!(
      first_trimester: create_trimester(Date.new(2024,8,1), Date.new(2024,10,31)),
      second_trimester: create_trimester(Date.new(2024,11,1), Date.new(2025,1,31)),
      third_trimester: create_trimester(Date.new(2025,2,1), Date.new(2025,4,30)),
      fourth_trimester: create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
    )
    
    # Create a school class for the teacher to fix layout issues
    @school_class = SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: @year,
      teacher: @teacher
    )
    @school_class.students << @student
    
    # Create a subject and assign it to the teacher
    @subject = Subject.create!(name: "Mathematics")
    @teacher.subjects << @subject
    
    # Create a lecture
    @lecture = Lecture.create!(
      start_time: "09:00",
      end_time: "10:30",
      week_day: "monday",
      subject: @subject,
      teacher: @teacher,
      school_class: @school_class,
      trimesters: [@year.first_trimester]
    )
    
    # Create an examination
    @examination = Examination.create!(
      title: "Test Exam",
      date: Date.new(2024,9,2), # A Monday in the first trimester
      lecture: @lecture
    )
    
    # Create a grade
    @grade = Grade.create!(
      value: 5.0,
      examination: @examination,
      student: @student
    )
  end

  def teardown
    super
    Grade.unscoped.delete_all
    Examination.unscoped.delete_all
    Lecture.unscoped.delete_all
    SchoolClass.unscoped.delete_all
    Subject.unscoped.delete_all
    Person.unscoped.delete_all
    Year.unscoped.delete_all
    Trimester.unscoped.delete_all
  end

  # Helper method for signing in
  def sign_in(person)
    post new_person_session_path, params: {
      person: {
        email: person.email,
        password: "password"
      }
    }
    assert_response :redirect
    follow_redirect!
  end

  # Index action tests
  
  test "should get index when signed in as dean" do
    sign_in @dean
    get grades_url
    assert_response :success
  end

  test "should get index when signed in as teacher" do
    sign_in @teacher
    get grades_url
    assert_response :success
  end

  test "should get index when signed in as student" do
    sign_in @student
    get grades_url
    assert_response :success
  end

  test "should redirect index when not signed in" do
    get grades_url
    assert_redirected_to new_person_session_path
  end

  # New action tests

  test "should get new when signed in as teacher who teaches the subject" do
    sign_in @teacher
    get new_grade_url
    assert_response :success
  end

  test "should get new when signed in as dean" do
    sign_in @dean
    get new_grade_url
    assert_response :success
  end

  test "should not get new when signed in as student" do
    sign_in @student
    get new_grade_url
    assert_redirected_to root_path
    assert_equal "Only deans and teachers can manage grades.", flash[:alert]
  end

  # Create action tests

  test "should create grade when signed in as teacher who teaches the subject" do
    sign_in @teacher
    
    # Create a new student for this test
    new_student = Student.create!(
      lastname: "New",
      firstname: "Student",
      email: "new.student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1111111111",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
    @school_class.students << new_student
    
    assert_difference("Grade.count") do
      post grades_url, params: {
        grade: {
          value: 5.50,
          examination_id: @examination.id,
          student_id: new_student.id
        }
      }
    end
    
    grade = Grade.last
    assert_redirected_to grade_url(grade)
    assert_equal "Grade was successfully created.", flash[:notice]
    assert_equal 5.50, grade.value
    assert_equal @examination, grade.examination
    assert_equal new_student, grade.student
  end

  test "should create grade when signed in as dean" do
    sign_in @dean
    
    # Create a new student for this test
    new_student = Student.create!(
      lastname: "New",
      firstname: "Student",
      email: "new.student-dean-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1111111111",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
    @school_class.students << new_student
    
    assert_difference("Grade.count") do
      post grades_url, params: {
        grade: {
          value: 5.50,
          examination_id: @examination.id,
          student_id: new_student.id
        }
      }
    end
    
    grade = Grade.last
    assert_redirected_to grade_url(grade)
    assert_equal "Grade was successfully created.", flash[:notice]
  end

  test "should not create grade when signed in as student" do
    sign_in @student
    assert_no_difference("Grade.count") do
      post grades_url, params: {
        grade: {
          value: 5.50,
          examination_id: @examination.id,
          student_id: @student.id
        }
      }
    end
    assert_redirected_to root_path
    assert_equal "Only deans and teachers can manage grades.", flash[:alert]
  end

  test "should not create grade with invalid data" do
    sign_in @teacher
    assert_no_difference("Grade.count") do
      post grades_url, params: {
        grade: {
          value: 6.50, # Invalid: greater than 6.00
          examination_id: @examination.id,
          student_id: @student.id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Show action tests

  test "should show grade when signed in as dean" do
    sign_in @dean
    get grade_url(@grade)
    assert_response :success
  end

  test "should show grade when signed in as teacher who teaches the subject" do
    sign_in @teacher
    get grade_url(@grade)
    assert_response :success
  end

  test "should show grade when signed in as student who owns the grade" do
    sign_in @student
    get grade_url(@grade)
    assert_response :success
  end

  # Edit action tests

  test "should get edit when signed in as teacher who teaches the subject" do
    sign_in @teacher
    get edit_grade_url(@grade)
    assert_response :success
  end

  test "should get edit when signed in as dean" do
    sign_in @dean
    get edit_grade_url(@grade)
    assert_response :success
  end

  test "should not get edit when signed in as student" do
    sign_in @student
    get edit_grade_url(@grade)
    assert_redirected_to root_path
    assert_equal "Only deans and teachers can manage grades.", flash[:alert]
  end

  # Update action tests

  test "should update grade when signed in as teacher who teaches the subject" do
    sign_in @teacher
    patch grade_url(@grade), params: {
      grade: {
        value: 5.75
      }
    }
    assert_redirected_to grade_url(@grade)
    @grade.reload
    assert_equal 5.75, @grade.value
  end

  test "should update grade when signed in as dean" do
    sign_in @dean
    patch grade_url(@grade), params: {
      grade: {
        value: 5.75
      }
    }
    assert_redirected_to grade_url(@grade)
    @grade.reload
    assert_equal 5.75, @grade.value
  end

  test "should not update grade when signed in as student" do
    sign_in @student
    original_value = @grade.value
    patch grade_url(@grade), params: {
      grade: {
        value: 5.75
      }
    }
    assert_redirected_to root_path
    assert_equal "Only deans and teachers can manage grades.", flash[:alert]
    @grade.reload
    assert_equal original_value, @grade.value
  end

  test "should not update grade with invalid data" do
    sign_in @teacher
    patch grade_url(@grade), params: {
      grade: {
        value: 0.50 # Invalid: less than 1.00
      }
    }
    assert_response :unprocessable_entity
    @grade.reload
    assert_not_equal 0.50, @grade.value
  end

  # Destroy action tests

  test "should soft delete grade when signed in as teacher who teaches the subject" do
    sign_in @teacher
    assert_no_difference("Grade.with_deleted.count") do
      delete grade_url(@grade)
    end
    assert_redirected_to grades_url
    assert_equal "Grade was successfully archived.", flash[:notice]
    
    # Verify the grade is soft deleted
    @grade.reload
    assert @grade.isDeleted
    assert_not Grade.exists?(@grade.id)
    assert Grade.with_deleted.exists?(@grade.id)
  end

  test "should soft delete grade when signed in as dean" do
    # Create a new grade for this test
    new_student = Student.create!(
      lastname: "Another",
      firstname: "Student",
      email: "another.student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "2222222222",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
    @school_class.students << new_student
    
    new_grade = Grade.new(
      value: 4.50,
      examination: @examination,
      student: new_student
    )
    new_grade.current_teacher = @teacher
    new_grade.save!
    
    sign_in @dean
    assert_no_difference("Grade.with_deleted.count") do
      delete grade_url(new_grade)
    end
    assert_redirected_to grades_url
    assert_equal "Grade was successfully archived.", flash[:notice]
    
    # Verify the grade is soft deleted
    new_grade.reload
    assert new_grade.isDeleted
    assert_not Grade.exists?(new_grade.id)
    assert Grade.with_deleted.exists?(new_grade.id)
  end

  test "should not destroy grade when signed in as student" do
    sign_in @student
    assert_no_difference("Grade.with_deleted.count") do
      delete grade_url(@grade)
    end
    assert_redirected_to root_path
    assert_equal "Only deans and teachers can manage grades.", flash[:alert]
    
    # Verify the grade is not deleted
    @grade.reload
    assert_not @grade.isDeleted
  end

  # Additional authorization tests

  test "should not manage grade for subject teacher doesn't teach" do
    # Create another subject and examination
    other_subject = Subject.create!(name: "History")
    other_teacher = Teacher.create!(
      lastname: "Brown",
      firstname: "Alice",
      email: "teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1111111111",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
    other_teacher.subjects << other_subject
    
    other_lecture = Lecture.create!(
      start_time: "11:00",
      end_time: "12:30",
      week_day: "tuesday",
      subject: other_subject,
      teacher: other_teacher,
      school_class: @school_class,
      trimesters: [@year.first_trimester]
    )
    
    other_examination = Examination.create!(
      title: "Other Exam",
      date: Date.new(2024,9,3),
      lecture: other_lecture
    )
    
    # Try to create a grade for an examination in a subject the teacher doesn't teach
    sign_in @teacher
    assert_no_difference("Grade.count") do
      post grades_url, params: {
        grade: {
          value: 5.50,
          examination_id: other_examination.id,
          student_id: @student.id
        }
      }
    end
    assert_redirected_to grades_url
    assert_equal "You can only manage grades for subjects you teach.", flash[:alert]
  end
  
  test "dean can manage grade for any subject" do
    # Create another subject and examination
    other_subject = Subject.create!(name: "History")
    other_teacher = Teacher.create!(
      lastname: "Brown",
      firstname: "Alice",
      email: "teacher-history-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1111111111",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
    other_teacher.subjects << other_subject
    
    other_lecture = Lecture.create!(
      start_time: "11:00",
      end_time: "12:30",
      week_day: "tuesday",
      subject: other_subject,
      teacher: other_teacher,
      school_class: @school_class,
      trimesters: [@year.first_trimester]
    )
    
    other_examination = Examination.create!(
      title: "Other Exam",
      date: Date.new(2024,9,3),
      lecture: other_lecture
    )
    
    # Dean should be able to create a grade for any examination
    sign_in @dean
    assert_difference("Grade.count") do
      post grades_url, params: {
        grade: {
          value: 5.50,
          examination_id: other_examination.id,
          student_id: @student.id
        }
      }
    end
    
    grade = Grade.last
    assert_redirected_to grade_url(grade)
    assert_equal "Grade was successfully created.", flash[:notice]
    assert_equal other_examination, grade.examination
  end
end
