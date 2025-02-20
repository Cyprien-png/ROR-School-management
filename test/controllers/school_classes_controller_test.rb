require "test_helper"

class SchoolClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @school_class = school_classes(:one)
  end

  test "should get index" do
    get school_classes_url
    assert_response :success
  end

  test "should get new" do
    get new_school_class_url
    assert_response :success
  end

  test "should create school_class" do
    assert_difference("SchoolClass.count") do
      post school_classes_url, params: { school_class: { grade: @school_class.grade, name: @school_class.name, year: @school_class.year } }
    end

    assert_redirected_to school_class_url(SchoolClass.last)
  end

  test "should show school_class" do
    get school_class_url(@school_class)
    assert_response :success
  end

  test "should get edit" do
    get edit_school_class_url(@school_class)
    assert_response :success
  end

  test "should update school_class" do
    patch school_class_url(@school_class), params: { school_class: { grade: @school_class.grade, name: @school_class.name, year: @school_class.year } }
    assert_redirected_to school_class_url(@school_class)
  end

  test "should destroy school_class" do
    assert_difference("SchoolClass.count", -1) do
      delete school_class_url(@school_class)
    end

    assert_redirected_to school_classes_url
  end
end
