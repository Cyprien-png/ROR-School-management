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
    Grade.create!(
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
    assert_includes duplicate_grade.errors[:student], "already has a grade for this examination"
  end

  test "should not create grade for student not in class" do
    other_student = create_student
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
    other_teacher = create_teacher
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
