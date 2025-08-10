require "test_helper"

class Apex::App::Preference::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_app_preference_language_url
    assert_response :success
  end

  # test "should update language with valid language code" do
  #   patch apex_app_preference_language_url, params: { language: "ja" }
  #   assert_response :redirect
  #   assert_equal "ja", session[:language]
  #   assert_match(/Language updated/, flash[:notice])
  # end

  test "should reject invalid language code" do
    patch apex_app_preference_language_url, params: { language: "invalid" }
    assert_response :unprocessable_entity
    assert_equal I18n.t('apex.app.preferences.languages.unsupported'), flash[:alert]
  end

  test "should handle missing language parameter" do
    patch apex_app_preference_language_url
    assert_response :unprocessable_entity
    assert_equal I18n.t('apex.app.preferences.languages.unsupported'), flash[:alert]
  end
end
