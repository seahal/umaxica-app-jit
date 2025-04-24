require "test_helper"

class Www::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_app_preference_cookie_url
    assert_select "a[href=?]", www_app_root_path
    assert_select "h1", I18n.t("www.app.preference.cookie.edit.h1")
    assert_select "label", I18n.t("www.app.preference.cookie.edit.accept_tracking_cookies")
    assert_select "form input[type=?]", "submit"
    assert_response :success
  end

  test "checking cookie policy" do
    get edit_www_app_preference_cookie_url
    assert_nil cookies[:accept_tracking_cookies]
    patch www_app_preference_cookie_url, params: { accept_tracking_cookies: 1 }
    assert cookies[:accept_tracking_cookies]
    assert_redirected_to edit_www_app_preference_cookie_url
    get edit_www_app_preference_cookie_url
    patch www_app_preference_cookie_url, params: { accept_tracking_cookies: "0" }
    assert cookies[:accept_tracking_cookies]
    assert_redirected_to edit_www_app_preference_cookie_url
  end
end
