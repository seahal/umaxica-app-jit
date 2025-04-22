require "test_helper"

class Www::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_www_app_preference_cookie_url
    assert_select "a[href=?]", www_app_root_path
    assert_select "h1", I18n.t("www.app.preference.cookie.edit.h1")
    assert_response :success
  end
end
