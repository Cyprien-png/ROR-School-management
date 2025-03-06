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
      SchoolClass.delete_all
      Subject.delete_all
      Person.unscoped.delete_all
    end
  end

  def teardown
    # Clean up database in correct order to avoid foreign key constraints
    ActiveRecord::Base.connection.disable_referential_integrity do
      SchoolClassesStudent.delete_all
      ActiveRecord::Base.connection.execute("DELETE FROM subjects_teachers")
      SchoolClass.delete_all
      Subject.delete_all
      Person.unscoped.delete_all
    end
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
