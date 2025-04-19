require "test_helper"

class Www::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_app_preference_cookie_url
    assert_response :success
  end
end
