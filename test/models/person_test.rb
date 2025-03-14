require "test_helper"

class PersonTest < ActiveSupport::TestCase
  # Disable transactional fixtures since we're using STI
  self.use_transactional_tests = false

  # Clean up database before each test
  def setup
    Person.delete_all
  end

  def teardown
    Person.delete_all
  end

  test "should list all person types" do
    # Given
    teacher = Teacher.create!(
      lastname: "Doe",
      firstname: "John",
      email: "john.doe@test.com",
      phone_number: "1234567890",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )

    student = Student.create!(
      lastname: "Smith",
      firstname: "Jane",
      email: "jane.smith@test.com",
      phone_number: "0987654321",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )

    dean = Dean.create!(
      lastname: "Johnson",
      firstname: "Emily",
      email: "emily.johnson@test.com",
      phone_number: "5551234567",
      password: "password",
      password_confirmation: "password"
    )

    # When
    all_people = Person.all.order(:lastname)

    # Then
    assert_equal 3, all_people.count, "Should have exactly 3 people"
    assert_equal [teacher, dean, student], all_people.to_a, "Should have all three types of people in lastname order"
    
    # Verify types
    assert_equal "Teacher", teacher.type, "First person should be a Teacher"
    assert_equal "Student", student.type, "Second person should be a Student"
    assert_equal "Dean", dean.type, "Third person should be a Dean"
  end

  test "student status enum works correctly" do
    # Given
    student = Student.create!(
      lastname: "Smith",
      firstname: "Jane",
      email: "jane.smith@test.com",
      phone_number: "0987654321",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )

    # Then - Check initial status
    assert student.in_formation?, "Student should start in formation"
    assert_not student.finished?, "Student should not be finished"

    # When - Change status
    student.finished!

    # Then - Verify status changed
    assert student.finished?, "Student should be finished"
    assert_not student.in_formation?, "Student should no longer be in formation"

    # When - Find by status
    in_formation_students = Student.in_formation
    finished_students = Student.finished

    # Then - Verify scopes work
    assert_equal 0, in_formation_students.count, "Should have no students in formation"
    assert_equal 1, finished_students.count, "Should have one finished student"
    assert_equal student, finished_students.first, "Should find our finished student"
  end
end
