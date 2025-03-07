ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # We're not using fixtures anymore since we're creating fresh instances
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup
    # Clean up database in correct order to avoid foreign key constraints
    ActiveRecord::Base.connection.disable_referential_integrity do
      SchoolClassesStudent.delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM subjects_teachers")
      ActiveRecord::Base.connection.execute("DELETE FROM lectures_trimesters")
      SchoolClass.delete_all
      Subject.delete_all
      Person.unscoped.delete_all
      Lecture.delete_all
      Trimester.delete_all
    end
    
    # Initialize timestamp for unique emails
    @timestamp = Time.current.to_f
  end

  def teardown
    # Clean up database in correct order to avoid foreign key constraints
    ActiveRecord::Base.connection.disable_referential_integrity do
      SchoolClassesStudent.delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM subjects_teachers")
      ActiveRecord::Base.connection.execute("DELETE FROM lectures_trimesters")
      SchoolClass.delete_all
      Subject.delete_all
      Person.unscoped.delete_all
      Lecture.delete_all
      Trimester.delete_all
    end
  end
  
  # Global helper methods for creating test users
  def create_dean
    @dean ||= Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )
  end

  def create_teacher
    @teacher ||= Teacher.create!(
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
    @student ||= Student.create!(
      lastname: "Doe",
      firstname: "Jane",
      email: "student-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "5555555555",
      status: :in_formation,
      password: "password",
      password_confirmation: "password"
    )
  end
  
  # Helper method for creating a school class
  def create_school_class(teacher = nil)
    teacher ||= create_teacher
    SchoolClass.create!(
      name: "Test Class",
      grade: 1,
      year: 2025,
      teacher: teacher
    )
  end
  
  # Helper method for creating a subject
  def create_subject
    @subject ||= Subject.create!(
      name: "Test Subject #{@timestamp}-#{SecureRandom.hex(4)}"
    )
  end
  
  # Helper method for creating a trimester
  def create_trimester(start_date = nil, end_date = nil)
    start_date ||= Date.new(2024,8,1)
    end_date ||= Date.new(2024,10,31)
    Trimester.create!(
      start_date: start_date,
      end_date: end_date
    )
  end
  
  # Helper method for creating a lecture
  def create_lecture(subject = nil)
    subject ||= create_subject
    trimester = create_trimester
    teacher = create_teacher
    teacher.subjects << subject unless teacher.subjects.include?(subject)
    
    # Create a school class for the lecture
    school_class = SchoolClass.create!(
      name: "Test Class #{@timestamp}-#{SecureRandom.hex(4)}",
      grade: 1,
      year: Year.create!(
        first_trimester: create_trimester,
        second_trimester: create_trimester(Date.new(2024,11,1), Date.new(2025,1,31)),
        third_trimester: create_trimester(Date.new(2025,2,1), Date.new(2025,4,30)),
        fourth_trimester: create_trimester(Date.new(2025,5,1), Date.new(2025,7,31))
      ),
      teacher: teacher
    )
    
    Lecture.create!(
      start_time: "09:00",
      end_time: "10:30",
      week_day: "monday",
      subject: subject,
      teacher: teacher,
      school_class: school_class,
      trimesters: [trimester]
    )
  end
end

# Include authentication helpers in both controller and integration tests
class ActionDispatch::IntegrationTest
  # For integration tests, we'll use manual sign in
  def sign_in(person)
    post person_session_path, params: {
      person: {
        email: person.email,
        password: "password"
      }
    }
    assert_response :redirect
    follow_redirect!
  end
  
  # Disable transactional tests since we're having issues
  self.use_transactional_tests = false
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
  
  # For controller tests, we need to set up the Devise mapping
  def sign_in(person)
    @request.env["devise.mapping"] = Devise.mappings[:person]
    super(person)
  end
  
  # Disable transactional tests since we're having issues
  self.use_transactional_tests = false
end
