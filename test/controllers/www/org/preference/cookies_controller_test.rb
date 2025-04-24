require "test_helper"

class Www::Org::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_org_preference_cookie_url
    assert_response :success
  end

  test "checking cookie policy" do
    get edit_www_org_preference_cookie_url
    assert_nil cookies[:accept_tracking_cookies]
    patch www_org_preference_cookie_url, params: { accept_tracking_cookies: 1 }
    assert cookies[:accept_tracking_cookies]
    assert_redirected_to edit_www_org_preference_cookie_url
    get edit_www_org_preference_cookie_url
    patch www_org_preference_cookie_url, params: { accept_tracking_cookies: "0" }
    assert cookies[:accept_tracking_cookies]
    assert_redirected_to edit_www_org_preference_cookie_url
  end
end
