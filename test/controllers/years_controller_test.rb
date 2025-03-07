require "test_helper"

class YearsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
    
    # Create a year with trimesters
    @year = Year.create!(
      first_trimester: Trimester.create!(start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31)),
      second_trimester: Trimester.create!(start_date: Date.new(2024,11,1), end_date: Date.new(2025,1,31)),
      third_trimester: Trimester.create!(start_date: Date.new(2025,2,1), end_date: Date.new(2025,4,30)),
      fourth_trimester: Trimester.create!(start_date: Date.new(2025,5,1), end_date: Date.new(2025,7,31))
    )
  end

  test "should get index when not logged in" do
    get years_url
    assert_redirected_to new_person_session_path
  end

  test "should get index when logged in" do
    sign_in @student
    get years_url
    assert_response :success
  end

  test "should not get new if not dean" do
    sign_in @teacher
    get new_year_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]

    sign_in @student
    get new_year_url
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should get new if dean" do
    sign_in @dean
    get new_year_url
    assert_response :success
  end

  test "should not create year if not dean" do
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

  test "should create year if dean" do
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
    
    # Verify the year was created with correct trimesters
    year = Year.last
    assert_equal Date.new(2024,8,1), year.first_trimester.start_date
    assert_equal Date.new(2024,10,31), year.first_trimester.end_date
    assert_equal Date.new(2024,11,1), year.second_trimester.start_date
    assert_equal Date.new(2025,1,31), year.second_trimester.end_date
    assert_equal Date.new(2025,2,1), year.third_trimester.start_date
    assert_equal Date.new(2025,4,30), year.third_trimester.end_date
    assert_equal Date.new(2025,5,1), year.fourth_trimester.start_date
    assert_equal Date.new(2025,7,31), year.fourth_trimester.end_date
  end

  test "should show year when logged in" do
    sign_in @student
    get year_url(@year)
    assert_response :success
  end

  test "should not get edit if not dean" do
    sign_in @teacher
    get edit_year_url(@year)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]

    sign_in @student
    get edit_year_url(@year)
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should get edit if dean" do
    sign_in @dean
    get edit_year_url(@year)
    assert_response :success
  end

  test "should not update year if not dean" do
    sign_in @teacher
    patch year_url(@year), params: { 
      year: {
        first_trimester_attributes: { start_date: Date.new(2024,8,1), end_date: Date.new(2024,10,31) }
      }
    }
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update year if dean" do
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

  test "should not destroy year if not dean" do
    sign_in @teacher
    assert_no_difference("Year.count") do
      delete year_url(@year)
    end
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should soft delete year if dean" do
    sign_in @dean
    assert_no_difference("Year.with_deleted.count") do
      delete year_url(@year)
    end
    assert_not Year.exists?(@year.id)
    assert Year.with_deleted.exists?(@year.id)
    assert_redirected_to years_url
  end
end 