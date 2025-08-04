require "test_helper"

class Apex::Org::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    ActionController::Base.allow_forgery_protection = true
    get edit_apex_org_preference_cookie_url
    assert_select "form" do
      assert_select "input[type='hidden'][name='authenticity_token']", count: 1
      assert_select "input[type='checkbox'][name='accept_tracking_cookies']", count: 1
      assert_select "label", I18n.t("www.app.preference.cookie.edit.accept_tracking_cookies")
      assert_select "input[type=?]", "submit"
    end
    assert_response :success
  end

  # test "checking cookie policy" do
  #   get edit_apex_org_preference_cookie_url
  #   assert_nil cookies[:accept_tracking_cookies]
  #   patch apex_org_preference_cookie_url, params: { accept_tracking_cookies: 1 }
  #   assert cookies[:accept_tracking_cookies]
  #   assert_redirected_to edit_apex_org_preference_cookie_url
  #   get edit_apex_org_preference_cookie_url
  #   patch apex_org_preference_cookie_url, params: { accept_tracking_cookies: "0" }
  #   assert cookies[:accept_tracking_cookies]
  #   assert_redirected_to edit_apex_org_preference_cookie_url
  # end
end
