require "test_helper"

class ExaminationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @examination = examinations(:one)
  end

  test "should get index" do
    get examinations_url
    assert_response :success
  end

  test "should get new" do
    get new_examination_url
    assert_response :success
  end

  test "should create examination" do
    assert_difference("Examination.count") do
      post examinations_url, params: { examination: { date: @examination.date, title: @examination.title } }
    end

    assert_redirected_to examination_url(Examination.last)
  end

  test "should show examination" do
    get examination_url(@examination)
    assert_response :success
  end

  test "should get edit" do
    get edit_examination_url(@examination)
    assert_response :success
  end

  test "should update examination" do
    patch examination_url(@examination), params: { examination: { date: @examination.date, title: @examination.title } }
    assert_redirected_to examination_url(@examination)
  end

  test "should destroy examination" do
    assert_difference("Examination.count", -1) do
      delete examination_url(@examination)
    end

    assert_redirected_to examinations_url
  end
end
