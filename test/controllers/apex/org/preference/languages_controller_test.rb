require "test_helper"

class Apex::Org::Preference::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_language_url
    assert_response :success
  end

  test "should update admin language to japanese" do
    patch apex_org_preference_language_url, params: { language: "ja" }
    assert_response :redirect
    assert_equal "ja", session[:admin_language]
    assert_match /Admin language updated to 日本語/, flash[:notice]
  end

  test "should update admin language to korean" do
    patch apex_org_preference_language_url, params: { language: "ko" }
    assert_response :redirect
    assert_equal "ko", session[:admin_language]
    assert_match /Admin language updated to 한국어/, flash[:notice]
  end

  test "should reject invalid admin language code" do
    patch apex_org_preference_language_url, params: { language: "invalid" }
    assert_response :unprocessable_entity
    assert_equal "Unsupported admin language selected", flash[:alert]
  end

  test "should handle missing language parameter" do
    patch apex_org_preference_language_url
    assert_response :unprocessable_entity
    assert_equal "Unsupported admin language selected", flash[:alert]
  end
end
