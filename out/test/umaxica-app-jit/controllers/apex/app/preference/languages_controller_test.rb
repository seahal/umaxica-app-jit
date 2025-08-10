require "test_helper"

class Apex::App::Preference::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_language_url
    assert_response :success
  end

  test "should update language" do
    patch apex_app_preference_language_url, params: { language: "en" }
    assert_response :redirect
  end
end
