require "test_helper"

class YearsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Clean up any existing data
    Year.unscoped.delete_all
    Trimester.unscoped.delete_all
    
    # Create test users
    @dean = create_dean
    @teacher = create_teacher
    @student = create_student
  end

  teardown do
    # Clean up test data
    Year.unscoped.delete_all
    Trimester.unscoped.delete_all
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
    # GIVEN a year in the database
    year = create_year
    
    # WHEN accessing the year as a student
    sign_in @student
    get year_url(year)
    
    # THEN the response should be successful
    assert_response :success
  end

  test "should not get edit if not dean" do
    # GIVEN a year in the database
    year = create_year
    
    # WHEN accessing edit as a teacher
    sign_in @teacher
    get edit_year_url(year)
    
    # THEN access should be denied
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]

    # WHEN accessing edit as a student
    sign_in @student
    get edit_year_url(year)
    
    # THEN access should be denied
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should get edit if dean" do
    # GIVEN a year in the database
    year = create_year
    
    # WHEN accessing edit as a dean
    sign_in @dean
    get edit_year_url(year)
    
    # THEN access should be granted
    assert_response :success
  end

  test "should not update year if not dean" do
    # GIVEN a year in the database
    year = create_year
    
    # WHEN trying to update as a teacher
    sign_in @teacher
    patch year_url(year), params: { 
      year: {
        first_trimester_attributes: { 
          id: year.first_trimester.id,
          start_date: Date.new(2024,8,1), 
          end_date: Date.new(2024,10,31) 
        }
      }
    }
    
    # THEN access should be denied
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should update year if dean" do
    # GIVEN a year in the database
    year = create_year
    
    # WHEN updating as a dean
    sign_in @dean
    patch year_url(year), params: { 
      year: {
        first_trimester_attributes: { 
          id: year.first_trimester.id, 
          start_date: Date.new(2024,9,1), 
          end_date: Date.new(2024,11,30) 
        },
        second_trimester_attributes: { 
          id: year.second_trimester.id, 
          start_date: Date.new(2024,12,1), 
          end_date: Date.new(2025,2,28) 
        },
        third_trimester_attributes: { 
          id: year.third_trimester.id, 
          start_date: Date.new(2025,3,1), 
          end_date: Date.new(2025,5,31) 
        },
        fourth_trimester_attributes: { 
          id: year.fourth_trimester.id, 
          start_date: Date.new(2025,6,1), 
          end_date: Date.new(2025,8,31) 
        }
      }
    }
    
    # THEN the update should succeed
    assert_redirected_to year_url(year)
    
    # And the changes should be saved
    year.reload
    assert_equal Date.new(2024,9,1), year.first_trimester.start_date
    assert_equal Date.new(2024,11,30), year.first_trimester.end_date
    assert_equal Date.new(2024,12,1), year.second_trimester.start_date
    assert_equal Date.new(2025,2,28), year.second_trimester.end_date
    assert_equal Date.new(2025,3,1), year.third_trimester.start_date
    assert_equal Date.new(2025,5,31), year.third_trimester.end_date
    assert_equal Date.new(2025,6,1), year.fourth_trimester.start_date
    assert_equal Date.new(2025,8,31), year.fourth_trimester.end_date
  end

  test "should not destroy year if not dean" do
    # GIVEN a year in the database
    year = create_year
    
    # WHEN trying to delete as a teacher
    sign_in @teacher
    assert_no_difference("Year.count") do
      delete year_url(year)
    end
    
    # THEN access should be denied
    assert_redirected_to root_path
    assert_equal "Only deans are allowed to perform this action.", flash[:alert]
  end

  test "should soft delete year if dean" do
    # GIVEN a year in the database
    year = create_year
    initial_count = Year.count
    initial_total = Year.unscoped.count
    
    # WHEN deleting as a dean
    sign_in @dean
    delete year_url(year)
    
    # THEN the year should be soft deleted
    assert_redirected_to years_url
    assert_equal initial_count - 1, Year.count, "Year should be removed from default scope"
    assert_equal initial_total, Year.unscoped.count, "Total number of years should not change"
    assert_not Year.exists?(year.id), "Year should not be found in default scope"
    assert Year.unscoped.exists?(year.id), "Year should still exist in database"
    
    # And it should be marked as deleted
    year.reload
    assert year.isDeleted, "Year should be marked as deleted"
  end
end 