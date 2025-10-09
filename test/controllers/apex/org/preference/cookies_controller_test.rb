require "test_helper"

class Apex::Org::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    ActionController::Base.allow_forgery_protection = true
    get edit_apex_org_preference_cookie_url
    assert_select "form" do
      assert_select "input[type='hidden'][name='authenticity_token']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
      assert_select "label", I18n.t("apex.org.preference.cookie.edit.accept_tracking_cookies")
      assert_select "input[type=?]", "submit"
    end
    assert_response :success
  end

  test "checking cookie policy" do
    ActionController::Base.allow_forgery_protection = true
    get edit_apex_org_preference_cookie_url
    assert_response :success
    # assert_select "h1", I18n.t("apex.org.preference.cookie.edit.h1")
    assert_select "div#hello-world-component", count: 0
    # assert_select "form[action=?]", apex_org_preference_cookie_url do
    assert_select "input[type='hidden'][name='authenticity_token']", count: 1
    assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
    assert_select "input[type='checkbox'][name='accept_tracking_cookies'][checked]", count: 0
    assert_select "label", I18n.t("apex.app.preference.cookie.edit.accept_tracking_cookies")
    assert_select "input[type=?]", "submit"
    # end
  end
end
