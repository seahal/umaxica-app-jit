require "test_helper"

class Peak::App::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  # Note: This controller exists but is not currently used in routes
  # The actual cookie preferences are handled by Peak::App::Privacy::CookiesController

  test "controller includes Cookie concern" do
    controller = Peak::App::Preference::CookiesController.new

    assert_includes controller.class, Cookie
  end
end
