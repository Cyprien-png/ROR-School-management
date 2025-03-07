require "test_helper"

class LecturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lecture = lectures(:one)
  end

  test "should get index" do
    get lectures_url
    assert_response :success
  end

  test "should get new" do
    get new_lecture_url
    assert_response :success
  end

  test "should create lecture" do
    assert_difference("Lecture.count") do
      post lectures_url, params: { lecture: { end_time: @lecture.end_time, start_time: @lecture.start_time, week_day: @lecture.week_day } }
    end

    assert_redirected_to lecture_url(Lecture.last)
  end

  test "should show lecture" do
    get lecture_url(@lecture)
    assert_response :success
  end

  test "should get edit" do
    get edit_lecture_url(@lecture)
    assert_response :success
  end

  test "should update lecture" do
    patch lecture_url(@lecture), params: { lecture: { end_time: @lecture.end_time, start_time: @lecture.start_time, week_day: @lecture.week_day } }
    assert_redirected_to lecture_url(@lecture)
  end

  test "should destroy lecture" do
    assert_difference("Lecture.count", -1) do
      delete lecture_url(@lecture)
    end

    assert_redirected_to lectures_url
  end
end
