require "test_helper"

class Apex::Org::Preference::LanguagesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_apex_org_preference_language_url
    assert_response :success
  end

  test "should update language" do
    patch apex_org_preference_language_url, params: { language: "en" }
    assert_response :no_content
  end
end
