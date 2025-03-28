require "test_helper"

class SchoolClassesControllerTest < ActionDispatch::IntegrationTest
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

  def create_academic_year
    Year.create!(
      first_trimester: Trimester.create!(start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31)),
      second_trimester: Trimester.create!(start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31)),
      third_trimester: Trimester.create!(start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30)),
      fourth_trimester: Trimester.create!(start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31))
    )
  end

  def create_school_class(teacher)
    SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: create_academic_year,
      teacher: teacher
    )
  end

  test "should add student to class when dean" do
    dean = create_dean
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    
    sign_in dean
    
    assert_difference -> { school_class.students.count }, 1 do
      post add_student_school_class_url(school_class), params: { student_id: student.id }
    end
    
    assert_redirected_to school_class_url(school_class)
    assert_equal "Student was successfully added to the class.", flash[:notice]
    
    # Reload to get updated associations
    school_class.reload
    assert school_class.students.include?(student)
  end

  test "should not add student to class when teacher" do
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    
    sign_in teacher
    
    assert_no_difference -> { school_class.students.count } do
      post add_student_school_class_url(school_class), params: { student_id: student.id }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Reload to get updated associations
    school_class.reload
    assert_not school_class.students.include?(student)
  end

  test "should not add student to class when student" do
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    
    sign_in student
    
    assert_no_difference -> { school_class.students.count } do
      post add_student_school_class_url(school_class), params: { student_id: student.id }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Reload to get updated associations
    school_class.reload
    assert_not school_class.students.include?(student)
  end

  test "should remove student from class when dean" do
    dean = create_dean
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    school_class.students << student
    
    sign_in dean
    
    assert_difference -> { school_class.students.count }, -1 do
      delete remove_student_school_class_url(school_class), params: { student_id: student.id }
    end
    
    assert_redirected_to school_class_url(school_class)
    assert_equal "Student was successfully removed from the class.", flash[:notice]
    
    # Reload to get updated associations
    school_class.reload
    assert_not school_class.students.include?(student)
  end

  test "should not remove student from class when teacher" do
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    school_class.students << student
    
    sign_in teacher
    
    assert_no_difference -> { school_class.students.count } do
      delete remove_student_school_class_url(school_class), params: { student_id: student.id }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Reload to get updated associations
    school_class.reload
    assert school_class.students.include?(student)
  end

  test "should not remove student from class when student" do
    teacher = create_teacher
    student = create_student
    other_student = create_student
    school_class = create_school_class(teacher)
    school_class.students << other_student
    
    sign_in student
    
    assert_no_difference -> { school_class.students.count } do
      delete remove_student_school_class_url(school_class), params: { student_id: other_student.id }
    end
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Reload to get updated associations
    school_class.reload
    assert school_class.students.include?(other_student)
  end

  test "should get index when signed in as any user type" do
    dean = create_dean
    teacher = create_teacher
    student = create_student
    create_school_class(teacher)

    # Test as dean
    sign_in dean
    get school_classes_url
    assert_response :success

    # Sign out and sign in as teacher
    delete destroy_person_session_path
    sign_in teacher
    get school_classes_url
    assert_response :success

    # Sign out and sign in as student
    delete destroy_person_session_path
    sign_in student
    get school_classes_url
    assert_response :success
  end

  test "should get new when dean" do
    dean = create_dean
    sign_in dean
    get new_school_class_url
    assert_response :success
  end

  test "should not get new when teacher" do
    teacher = create_teacher
    sign_in teacher
    get new_school_class_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not get new when student" do
    student = create_student
    sign_in student
    get new_school_class_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create school_class when dean" do
    dean = create_dean
    teacher = create_teacher
    year = create_academic_year
    sign_in dean
    
    assert_difference("SchoolClass.count") do
      post school_classes_url, params: {
        school_class: {
          name: "New Class",
          grade: 2,
          year_id: year.id,
          teacher_id: teacher.id
        }
      }
    end

    assert_redirected_to school_class_url(SchoolClass.last)
  end

  test "should not create school_class when teacher" do
    teacher = create_teacher
    year = create_academic_year
    sign_in teacher
    
    assert_no_difference("SchoolClass.count") do
      post school_classes_url, params: {
        school_class: {
          name: "New Class",
          grade: 2,
          year_id: year.id,
          teacher_id: teacher.id
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should not create school_class when student" do
    student = create_student
    teacher = create_teacher
    year = create_academic_year
    sign_in student
    
    assert_no_difference("SchoolClass.count") do
      post school_classes_url, params: {
        school_class: {
          name: "New Class",
          grade: 2,
          year_id: year.id,
          teacher_id: teacher.id
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should show school_class for any user type" do
    dean = create_dean
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)

    # Test as dean
    sign_in dean
    get school_class_url(school_class)
    assert_response :success

    # Sign out and sign in as teacher
    delete destroy_person_session_path
    sign_in teacher
    get school_class_url(school_class)
    assert_response :success

    # Sign out and sign in as student
    delete destroy_person_session_path
    sign_in student
    get school_class_url(school_class)
    assert_response :success
  end

  test "should get edit when dean" do
    dean = create_dean
    teacher = create_teacher
    school_class = create_school_class(teacher)
    
    sign_in dean
    get edit_school_class_url(school_class)
    assert_response :success
  end

  test "should not get edit when teacher" do
    teacher = create_teacher
    school_class = create_school_class(teacher)
    
    sign_in teacher
    get edit_school_class_url(school_class)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update school_class when dean" do
    dean = create_dean
    teacher = create_teacher
    new_teacher = create_teacher
    school_class = create_school_class(teacher)
    year = create_academic_year
    
    sign_in dean
    patch school_class_url(school_class), params: {
      school_class: {
        name: "Updated Class",
        grade: 3,
        year_id: year.id,
        teacher_id: new_teacher.id
      }
    }
    
    assert_redirected_to school_class_url(school_class)
    
    # Verify changes
    school_class.reload
    assert_equal "Updated Class", school_class.name
    assert_equal 3, school_class.grade
    assert_equal year, school_class.year
    assert_equal new_teacher, school_class.teacher
  end

  test "should not update school_class when teacher" do
    teacher = create_teacher
    new_teacher = create_teacher
    school_class = create_school_class(teacher)
    year = create_academic_year
    
    sign_in teacher
    patch school_class_url(school_class), params: {
      school_class: {
        name: "Updated Class",
        grade: 3,
        year_id: year.id,
        teacher_id: new_teacher.id
      }
    }
    
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should destroy school_class when dean" do
    dean = create_dean
    teacher = create_teacher
    school_class = create_school_class(teacher)
    
    sign_in dean
    
    # Count both active and soft-deleted classes before deletion
    active_classes_before = SchoolClass.count
    deleted_classes_before = SchoolClass.with_deleted.where(isDeleted: true).count
    
    delete school_class_url(school_class)

    # Verify counts after deletion
    assert_equal active_classes_before - 1, SchoolClass.count, "Active classes count should decrease by 1"
    assert_equal deleted_classes_before + 1, SchoolClass.with_deleted.where(isDeleted: true).count, "Deleted classes count should increase by 1"
    
    # Verify the specific class is now marked as deleted
    school_class.reload
    assert school_class.isDeleted?, "School class should be marked as deleted"
    
    # Verify the class appears in the deleted list
    assert_includes SchoolClass.with_deleted.where(isDeleted: true), school_class, "School class should be in the deleted list"

    assert_redirected_to school_classes_url
    assert_equal "School class was successfully deleted.", flash[:notice]
  end

  test "should not destroy school_class when teacher" do
    teacher = create_teacher
    school_class = create_school_class(teacher)
    
    sign_in teacher
    assert_no_difference("SchoolClass.count") do
      delete school_class_url(school_class)
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the school class is not soft deleted
    school_class.reload
    assert_not school_class.isDeleted
  end

  test "should get deleted school classes when dean" do
    dean = create_dean
    teacher = create_teacher
    school_class = create_school_class(teacher)
    school_class.update(isDeleted: true)
    
    sign_in dean
    get deleted_school_classes_url
    assert_response :success
  end

  test "should not get deleted school classes when not dean" do
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    school_class.update(isDeleted: true)
    
    # Test as teacher
    sign_in teacher
    get deleted_school_classes_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Test as student
    sign_in student
    get deleted_school_classes_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should undelete school class when dean" do
    dean = create_dean
    teacher = create_teacher
    school_class = create_school_class(teacher)
    school_class.update(isDeleted: true)
    
    sign_in dean
    patch undelete_school_class_url(school_class)
    
    assert_redirected_to school_classes_url
    assert_equal "School class was successfully restored.", flash[:notice]
    
    # Verify the school class is undeleted
    school_class.reload
    assert_not school_class.isDeleted
  end

  test "should not undelete school class when not dean" do
    teacher = create_teacher
    student = create_student
    school_class = create_school_class(teacher)
    school_class.update(isDeleted: true)
    
    # Test as teacher
    sign_in teacher
    patch undelete_school_class_url(school_class)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Test as student
    sign_in student
    patch undelete_school_class_url(school_class)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
    
    # Verify the school class is still deleted
    school_class.reload
    assert school_class.isDeleted
  end

  # ADD STUDENT TESTS
  
  test "should add student to class when signed in as dean" do
    sign_in @dean
    student = create_student
    
    assert_difference -> { @school_class.students.count }, 1 do
      post add_student_school_class_url(@school_class), params: { student_id: student.id }
    end
    
    assert_redirected_to school_class_url(@school_class)
    assert_equal "Student was successfully added to the class.", flash[:notice]
    assert_includes @school_class.students, student
  end
  
  test "should not add student to multiple classes from the same academic year" do
    sign_in @dean
    student = create_student
    
    # Get the year from the existing school class
    year = @school_class.year
    
    # Create another class in the same academic year
    second_class = SchoolClass.create!(
      name: "Test Class 2-#{@timestamp}",
      grade: 2,
      teacher: @teacher,
      year: year
    )
    
    # Add student to the first class
    post add_student_school_class_url(@school_class), params: { student_id: student.id }
    assert_redirected_to school_class_url(@school_class)
    assert_equal "Student was successfully added to the class.", flash[:notice]
    assert_includes @school_class.students.reload, student
    
    # Try to add student to the second class (should fail)
    post add_student_school_class_url(second_class), params: { student_id: student.id }
    assert_redirected_to school_class_url(second_class)
    assert_match /Student is already assigned to a class in the academic year/, flash[:alert]
    assert_not_includes second_class.students.reload, student
  end
  
  test "should add student to classes from different academic years" do
    sign_in @dean
    student = create_student
    
    # Create a different academic year
    second_year = Year.create!(
      first_trimester: create_trimester(Date.new(2025,8,1), Date.new(2025,10,31)),
      second_trimester: create_trimester(Date.new(2025,11,1), Date.new(2026,1,31)),
      third_trimester: create_trimester(Date.new(2026,2,1), Date.new(2026,4,30)),
      fourth_trimester: create_trimester(Date.new(2026,5,1), Date.new(2026,7,31))
    )
    
    # Create another class in a different academic year
    second_class = SchoolClass.create!(
      name: "Test Class 2-#{@timestamp}",
      grade: 2,
      teacher: @teacher,
      year: second_year
    )
    
    # Add student to the first class
    post add_student_school_class_url(@school_class), params: { student_id: student.id }
    assert_redirected_to school_class_url(@school_class)
    assert_equal "Student was successfully added to the class.", flash[:notice]
    assert_includes @school_class.students, student
    
    # Add student to the second class (should succeed)
    post add_student_school_class_url(second_class), params: { student_id: student.id }
    assert_redirected_to school_class_url(second_class)
    assert_equal "Student was successfully added to the class.", flash[:notice]
    assert_includes second_class.students, student
  end
end
