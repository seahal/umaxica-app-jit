require "test_helper"

class Apex::Com::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  # Note: This controller exists but is not currently used in routes
  # The actual cookie preferences are handled by Apex::Com::Privacy::CookiesController

  test "controller includes Cookie concern" do
    controller = Apex::Com::Preference::CookiesController.new

    assert_includes controller.class, Cookie
  end
end
