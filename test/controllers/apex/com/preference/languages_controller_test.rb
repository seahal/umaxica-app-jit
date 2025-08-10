require "test_helper"

class Apex::Com::Preference::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_com_preference_language_url
    assert_response :success
  end

  test "should update language with valid language code" do
    patch apex_com_preference_language_url, params: { language: "ja" }
    assert_response :redirect
    assert_equal "ja", session[:language]
    assert_match(/Language preference updated/, flash[:notice])
  end

  test "should update language to chinese" do
    patch apex_com_preference_language_url, params: { language: "zh" }
    assert_response :redirect
    assert_equal "zh", session[:language]
    assert_match(/Language preference updated to 中文/, flash[:notice])
  end

  test "should reject invalid language code" do
    patch apex_com_preference_language_url, params: { language: "invalid" }
    assert_response :unprocessable_entity
    assert_equal "Unsupported language selected", flash[:alert]
  end

  test "should handle missing language parameter" do
    patch apex_com_preference_language_url
    assert_response :unprocessable_entity
    assert_equal "Unsupported language selected", flash[:alert]
  end
end
