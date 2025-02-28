require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Create a dean for testing
    @dean = Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )

    # Create a test person for show action
    @person = Teacher.create!(
      lastname: "Doe",
      firstname: "John",
      email: "john.doe@test.com",
      phone_number: "0987654321",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )

    # Sign in before each test
    sign_in_as(@dean)
  end

  teardown do
    Person.delete_all
  end

  test "should get index" do
    get people_url
    assert_response :success
  end

  test "should show person" do
    get person_url(@person)
    assert_response :success
  end

  test "should redirect index when not signed in" do
    sign_out :person
    get people_url
    assert_redirected_to new_person_session_path
  end

  test "should redirect show when not signed in" do
    sign_out :person
    get person_url(@person)
    assert_redirected_to new_person_session_path
  end
end
