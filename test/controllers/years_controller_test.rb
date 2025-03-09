require "test_helper"

class YearsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    super
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    @year = create_year
  end

  test "should get index when authenticated" do
    sign_in @dean
    get years_url
    assert_response :success
  end

  test "should redirect index when not authenticated" do
    get years_url
    assert_redirected_to new_person_session_path
  end

  test "should get new when dean" do
    sign_in @dean
    get new_year_url
    assert_response :success
  end

  test "should not get new when not dean" do
    sign_in @teacher
    get new_year_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should create year when dean" do
    sign_in @dean
    assert_difference("Year.count") do
      post years_url, params: {
        year: {
          first_trimester_attributes: { start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31) },
          second_trimester_attributes: { start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31) },
          third_trimester_attributes: { start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30) },
          fourth_trimester_attributes: { start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31) }
        }
      }
    end

    assert_redirected_to year_url(Year.last)
  end

  test "should not create year when not dean" do
    sign_in @teacher
    assert_no_difference("Year.count") do
      post years_url, params: {
        year: {
          first_trimester_attributes: { start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31) },
          second_trimester_attributes: { start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31) },
          third_trimester_attributes: { start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30) },
          fourth_trimester_attributes: { start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31) }
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should show year when authenticated" do
    sign_in @student
    get year_url(@year)
    assert_response :success
  end

  test "should not show year when not authenticated" do
    get year_url(@year)
    assert_redirected_to new_person_session_path
  end

  test "should get edit when dean" do
    sign_in @dean
    get edit_year_url(@year)
    assert_response :success
  end

  test "should not get edit when not dean" do
    sign_in @teacher
    get edit_year_url(@year)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update year when dean" do
    sign_in @dean
    patch year_url(@year), params: {
      year: {
        first_trimester_attributes: { 
          id: @year.first_trimester.id, 
          start_date: Date.new(2024,8,1), 
          end_date: Date.new(2024,10,31) 
        }
      }
    }
    assert_redirected_to year_url(@year)
  end

  test "should not update year when not dean" do
    sign_in @teacher
    patch year_url(@year), params: {
      year: {
        first_trimester_attributes: { 
          id: @year.first_trimester.id, 
          start_date: Date.new(2024,8,1), 
          end_date: Date.new(2024,10,31) 
        }
      }
    }
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should destroy year when dean" do
    sign_in @dean
    year = create_year # Create a new year specifically for this test
    
    assert_difference("Year.count", -1) do
      delete year_url(year)
    end
    
    assert_redirected_to years_url
    assert year.reload.isDeleted # Verify it was soft deleted
  end

  test "should not destroy year when not dean" do
    sign_in @teacher
    assert_no_difference("Year.count") do
      delete year_url(@year)
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end
end 