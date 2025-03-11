require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def setup
    @timestamp = Time.current.to_f
    @student = create_student
    @year = create_year
    @teacher = create_teacher
  end

  test "should not allow student to be in multiple classes from the same academic year" do
    # Create two school classes in the same academic year
    class1 = SchoolClass.create!(
      name: "Class 1-#{@timestamp}",
      grade: 1,
      teacher: @teacher,
      year: @year
    )
    
    class2 = SchoolClass.create!(
      name: "Class 2-#{@timestamp}",
      grade: 2,
      teacher: @teacher,
      year: @year
    )
    
    # Add student to the first class
    @student.school_classes << class1
    assert_includes @student.school_classes, class1
    
    # Try to add student to the second class (should fail)
    @student.school_classes << class2
    assert @student.errors.any?
    assert_includes @student.errors.full_messages.to_sentence, "Cannot be assigned to multiple school classes in the same academic year"
    
    # Verify that the student is only in the first class
    @student.reload
    assert_includes @student.school_classes, class1
    assert_not_includes @student.school_classes, class2
  end
  
  test "should allow student to be in multiple classes from different academic years" do
    # Create a second year
    second_year = Year.create!(
      first_trimester: create_trimester(Date.new(2025,8,1), Date.new(2025,10,31)),
      second_trimester: create_trimester(Date.new(2025,11,1), Date.new(2026,1,31)),
      third_trimester: create_trimester(Date.new(2026,2,1), Date.new(2026,4,30)),
      fourth_trimester: create_trimester(Date.new(2026,5,1), Date.new(2026,7,31))
    )
    
    # Create two school classes in different academic years
    class1 = SchoolClass.create!(
      name: "Class 1-#{@timestamp}",
      grade: 1,
      teacher: @teacher,
      year: @year
    )
    
    class2 = SchoolClass.create!(
      name: "Class 2-#{@timestamp}",
      grade: 2,
      teacher: @teacher,
      year: second_year
    )
    
    # Add student to both classes
    @student.school_classes << class1
    @student.school_classes << class2
    
    # Verify that the student is in both classes
    @student.reload
    assert_includes @student.school_classes, class1
    assert_includes @student.school_classes, class2
    assert_equal 2, @student.school_classes.count
  end
end
