require "test_helper"

class Apex::Com::Preference::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_language_url
    assert_response :success
  end

  test "should update language" do
    patch apex_com_preference_language_url, params: { language: "en" }
    assert_response :redirect
  end
end
