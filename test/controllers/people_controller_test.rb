require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    @timestamp = Time.current.to_f
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
      lastname: "Doe",
      firstname: "John",
      email: "teacher-#{@timestamp}-#{SecureRandom.hex(4)}@test.com",
      phone_number: "0987654321",
      iban: "GB29NWBK60161331926819",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "should get index" do
    dean = create_dean
    sign_in dean
    get people_url
    assert_response :success
  end

  test "should show person" do
    dean = create_dean
    teacher = create_teacher
    sign_in dean
    get person_url(teacher)
    assert_response :success
  end

  test "should redirect index when not signed in" do
    get people_url
    assert_redirected_to new_person_session_path
  end

  test "should redirect show when not signed in" do
    teacher = create_teacher
    get person_url(teacher)
    assert_redirected_to new_person_session_path
  end
end
