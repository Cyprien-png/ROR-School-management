require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create and sign in a dean for testing
    @dean = Dean.create!(
      lastname: "Admin",
      firstname: "Test",
      email: "admin@test.com",
      phone_number: "1234567890",
      password: "password",
      password_confirmation: "password"
    )
    
    # Sign in the dean
    post person_session_path, params: { 
      person: { 
        email: @dean.email, 
        password: "password" 
      } 
    }

    # Create a test person for other actions
    @person = Teacher.create!(
      lastname: "Doe",
      firstname: "John",
      email: "john.doe@test.com",
      phone_number: "0987654321",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
  end

  teardown do
    Person.delete_all
  end

  test "should get index" do
    get people_url
    assert_response :success
  end

  test "should get new" do
    get new_person_url
    assert_response :success
  end

  test "should create person" do
    assert_difference("Person.count") do
      post people_url, params: { 
        person: { 
          type: "Teacher",
          email: "new.teacher@test.com", 
          firstname: "New", 
          lastname: "Teacher", 
          phone_number: "5555555555",
          iban: "GB29NWBK60161331926819",
          password: "password",
          password_confirmation: "password"
        } 
      }
    end

    assert_redirected_to person_url(Person.last)
  end

  test "should show person" do
    get person_url(@person)
    assert_response :success
  end

  test "should get edit" do
    get edit_person_url(@person)
    assert_response :success
  end

  test "should update person" do
    patch person_url(@person), params: { 
      person: { 
        email: "updated.email@test.com", 
        firstname: "Updated", 
        lastname: "Name", 
        phone_number: "9999999999"
      } 
    }
    assert_redirected_to person_url(@person)
  end

  test "should destroy person" do
    assert_difference("Person.count", -1) do
      delete person_url(@person)
    end

    assert_redirected_to people_url
  end
end
