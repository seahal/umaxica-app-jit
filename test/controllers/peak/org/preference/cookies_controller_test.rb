# frozen_string_literal: true

require "test_helper"

class Peak::Org::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  # Note: This controller exists but is not currently used in routes
  # The actual cookie preferences are handled by Peak::Org::Privacy::CookiesController

  test "controller includes Cookie concern" do
    controller = Peak::Org::Preference::CookiesController.new

    assert_includes controller.class, Cookie
  end
end
