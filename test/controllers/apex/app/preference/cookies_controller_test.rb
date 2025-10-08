require "test_helper"

class Apex::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    original_forgery_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    get edit_apex_app_preference_cookie_url

    assert_response :success
    assert_select "h1", I18n.t("apex.app.preference.cookie.edit.h1")
    assert_select "div#hello-world-component", count: 1
    assert_select "form[action=?]", apex_app_preference_cookie_url do
      assert_select "input[type='hidden'][name='authenticity_token']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0
      assert_select "label", I18n.t("apex.app.preference.cookie.edit.accept_tracking_cookies")
      assert_select "input[type='submit']", count: 1
    end
  ensure
    ActionController::Base.allow_forgery_protection = original_forgery_setting
  end

  test "submitting the form toggles the checkbox via persisted preference" do
    original_forgery_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false

    get edit_apex_app_preference_cookie_url
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0

    patch apex_app_preference_cookie_url, params: { accept_tracking_cookies: "1" }
    follow_redirect!
    assert_response :success
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 1

    patch apex_app_preference_cookie_url, params: { accept_tracking_cookies: "0" }
    follow_redirect!
    assert_response :success
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0
  ensure
    ActionController::Base.allow_forgery_protection = original_forgery_setting
  end
end
