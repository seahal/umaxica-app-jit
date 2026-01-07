# frozen_string_literal: true

require "test_helper"

class Apex::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  # Note: This controller exists but is not currently used in routes
  # The actual cookie preferences are handled by Apex::App::Privacy::CookiesController

  test "should get edit" do
    get edit_apex_app_preference_cookie_url
    assert_response :success
  end
end
