require "test_helper"

class TrimestersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trimesters_index_url
    assert_response :success
  end

  test "should get show" do
    get trimesters_show_url
    assert_response :success
  end

  test "should get new" do
    get trimesters_new_url
    assert_response :success
  end

  test "should get edit" do
    get trimesters_edit_url
    assert_response :success
  end

  test "should get create" do
    get trimesters_create_url
    assert_response :success
  end

  test "should get update" do
    get trimesters_update_url
    assert_response :success
  end

  test "should get destroy" do
    get trimesters_destroy_url
    assert_response :success
  end
end
