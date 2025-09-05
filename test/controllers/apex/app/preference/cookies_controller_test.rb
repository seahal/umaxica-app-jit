require "test_helper"

class Apex::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    ActionController::Base.allow_forgery_protection = true
    get edit_apex_app_preference_cookie_url
    # assert_select "a[href=?]", apex_app_root_path
    assert_select "h1", I18n.t("apex.app.preference.cookie.edit.h1")
    assert_select "form" do
      assert_select "input[type='hidden'][name='authenticity_token']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
      assert_select "label", I18n.t("apex.app.preference.cookie.edit.accept_tracking_cookies")
      assert_select "input[type=?]", "submit"
    end
    assert_response :success
  end
end
