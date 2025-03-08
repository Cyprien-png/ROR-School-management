require "application_system_test_case"

class ExaminationsTest < ApplicationSystemTestCase
  setup do
    @examination = examinations(:one)
  end

  test "visiting the index" do
    visit examinations_url
    assert_selector "h1", text: "Examinations"
  end

  test "should create examination" do
    visit examinations_url
    click_on "New examination"

    fill_in "Date", with: @examination.date
    fill_in "Title", with: @examination.title
    click_on "Create Examination"

    assert_text "Examination was successfully created"
    click_on "Back"
  end

  test "should update Examination" do
    visit examination_url(@examination)
    click_on "Edit this examination", match: :first

    fill_in "Date", with: @examination.date
    fill_in "Title", with: @examination.title
    click_on "Update Examination"

    assert_text "Examination was successfully updated"
    click_on "Back"
  end

  test "should destroy Examination" do
    visit examination_url(@examination)
    click_on "Destroy this examination", match: :first

    assert_text "Examination was successfully destroyed"
  end
end
