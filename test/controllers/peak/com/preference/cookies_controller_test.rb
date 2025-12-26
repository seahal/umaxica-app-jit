# frozen_string_literal: true

require "test_helper"

class Peak::Com::Preference::CookiesControllerTest < ActionDispatch::IntegrationTest
  # Note: This controller exists but is not currently used in routes
  # The actual cookie preferences are handled by Peak::Com::Privacy::CookiesController

  test "controller includes Cookie concern" do
    controller = Peak::Com::Preference::CookiesController.new

    assert_includes controller.class, Cookie
  end
end
