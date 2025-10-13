require "test_helper"

class Apex::Com::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    ActionController::Base.allow_forgery_protection = true
    get edit_apex_com_preference_cookie_url
    assert_select "form" do
      assert_select "input[type='hidden'][name='authenticity_token']"
      assert_select "input[type='checkbox'][name='accept_functional_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_performance_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_targeting_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
      assert_select "input[type=?]", "submit"
    end
    assert_response :success
  end

  test "should get edit - 2" do
    ActionController::Base.allow_forgery_protection = true
    get edit_apex_com_preference_cookie_url
    assert_response :success
    assert_select "h1", I18n.t("apex.com.preference.cookie.edit.h1")
    assert_select "div#hello-world-component", count: 0
    assert_select "form[action=?]", apex_com_preference_cookie_url do
      assert_select "input[type='hidden'][name='authenticity_token']", count: 1
      assert_select "input[type='checkbox'][name='accept_functional_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_performance_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_targeting_cookies']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0
      assert_select "label", I18n.t("apex.com.preference.cookie.edit.accept_functional_cookies")
      assert_select "label", I18n.t("apex.com.preference.cookie.edit.accept_performance_cookies")
      assert_select "label", I18n.t("apex.com.preference.cookie.edit.accept_targeting_cookies")
      assert_select "label", I18n.t("apex.com.preference.cookie.edit.accept_tracking_cookies")
      assert_select "input[type=?]", "submit"
    end
  end

  test "submitting the form persists corporate cookie preferences" do
    original_forgery_setting = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false

    get edit_apex_com_preference_cookie_url
    assert_select "input[type='checkbox'][name='accept_functional_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_performance_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_targeting_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0

    patch apex_com_preference_cookie_url,
          params: {
            accept_functional_cookies: "1",
            accept_performance_cookies: "1",
            accept_targeting_cookies: "1",
            accept_tracking_cookies: "1"
          }
    follow_redirect!
    assert_response :success
    assert_select "input[type='checkbox'][name='accept_functional_cookies'][checked]", count: 1
    assert_select "input[type='checkbox'][name='accept_performance_cookies'][checked]", count: 1
    assert_select "input[type='checkbox'][name='accept_targeting_cookies'][checked]", count: 1
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0

    patch apex_com_preference_cookie_url,
          params: {
            accept_functional_cookies: "0",
            accept_performance_cookies: "0",
            accept_targeting_cookies: "0",
            accept_tracking_cookies: "0"
          }
    follow_redirect!
    assert_response :success
    assert_select "input[type='checkbox'][name='accept_functional_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_performance_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_targeting_cookies'][checked]", count: 0
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0
  ensure
    ActionController::Base.allow_forgery_protection = original_forgery_setting
  end
end
