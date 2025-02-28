ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # We're not using fixtures for these tests
    # fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Custom authentication helper for controller tests
module AuthenticationHelper
  def sign_in_as(person)
    sign_out :person
    post person_session_path, params: {
      person: {
        email: person.email,
        password: "password"
      }
    }
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationHelper
end
