require "test_helper"

class GradeTest < ActiveSupport::TestCase
  def setup
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    @subject = create_subject
    @teacher.subjects << @subject
    
    # Create a school class and add the student
    @school_class = create_school_class(@teacher)
    @school_class.students << @student
    
    # Create a lecture and examination
    @lecture = create_lecture(@subject, @teacher, @school_class)
    @examination = create_examination(@lecture)
  end

  test "should create valid grade" do
    grade = Grade.new(
      value: 5.50,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    assert grade.valid?
  end

  test "should not create grade with value less than 1.00" do
    grade = Grade.new(
      value: 0.99,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    assert_not grade.valid?
    assert_includes grade.errors[:value], "must be between 1.00 and 6.00"
  end

  test "should not create grade with value greater than 6.00" do
    grade = Grade.new(
      value: 6.01,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    assert_not grade.valid?
    assert_includes grade.errors[:value], "must be between 1.00 and 6.00"
  end

  test "should not create grade without value" do
    grade = Grade.new(
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    assert_not grade.valid?
    assert_includes grade.errors[:value], "can't be blank"
  end

  test "should not create duplicate grade for same student and examination" do
    # First create a grade
    first_grade = Grade.create!(
      value: 5.00,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    
    # Try to create another grade for the same student and examination
    duplicate_grade = Grade.new(
      value: 4.50,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    
    assert_not duplicate_grade.valid?
    assert_includes duplicate_grade.errors.full_messages, "Student already has a grade for this examination"
  end

  test "should not create grade for student not in class" do
    # Create a new student that is not in the class
    other_student = Student.create!(
      lastname: "Other",
      firstname: "Student",
      email: "other.student-#{Time.current.to_f}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "9999999999",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
    
    # Verify the student is not in the class
    assert_not @school_class.students.include?(other_student)
    
    grade = Grade.new(
      value: 5.00,
      examination: @examination,
      student: other_student,
      current_teacher: @teacher
    )
    
    assert_not grade.valid?
    assert_includes grade.errors[:student], "must be in the lecture's class"
  end

  test "should not create grade if teacher doesn't teach subject" do
    # Create a new teacher that doesn't teach the subject
    other_teacher = Teacher.create!(
      lastname: "Other",
      firstname: "Teacher",
      email: "other.teacher-#{Time.current.to_f}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "8888888888",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
    
    # Verify the teacher doesn't teach the subject
    assert_not other_teacher.subjects.include?(@subject)
    
    grade = Grade.new(
      value: 5.00,
      examination: @examination,
      student: @student,
      current_teacher: other_teacher
    )
    
    assert_not grade.valid?
    assert_includes grade.errors[:examination], "must be for a subject you teach"
  end

  test "should not create grade for deleted examination" do
    @examination.soft_delete
    
    grade = Grade.new(
      value: 5.00,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    
    assert_not grade.valid?
    assert_includes grade.errors[:examination], "cannot be a deleted examination"
  end

  test "should soft delete grade" do
    grade = Grade.create!(
      value: 5.00,
      examination: @examination,
      student: @student,
      current_teacher: @teacher
    )
    
    grade.soft_delete
    assert grade.isDeleted
    assert_not Grade.exists?(grade.id)
    assert Grade.with_deleted.exists?(grade.id)
  end
end
