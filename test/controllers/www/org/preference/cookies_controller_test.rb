require "test_helper"

class Www::Org::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_org_preference_cookie_url
    assert_response :success
  end
end
