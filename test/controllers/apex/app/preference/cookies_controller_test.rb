# frozen_string_literal: true

require "test_helper"

class Apex::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  # Note: This controller exists but is not currently used in routes
  # The actual cookie preferences are handled by Apex::App::Privacy::CookiesController

  test "should get edit" do
    get edit_apex_app_preference_cookie_url
    assert_response :success
  end

  test "should update cookies" do
    patch apex_app_preference_cookie_url, params: {
      accept_functional_cookies: "1",
      accept_performance_cookies: "0",
      accept_targeting_cookies: "1",
    }

    assert_redirected_to Regexp.new(Regexp.escape(edit_apex_app_preference_cookie_url))
    assert cookies[:accept_functional_cookies]
    assert cookies[:accept_performance_cookies]
    assert cookies[:accept_targeting_cookies]
  end

  test "controller includes Cookie concern" do
    controller = Apex::App::Preference::CookiesController.new

    assert_includes controller.class, Cookie
  end
end
