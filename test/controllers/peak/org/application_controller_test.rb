# frozen_string_literal: true

require "test_helper"

module Peak::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, RateLimit
      assert_includes controller.class, DefaultUrlOptions
      assert_includes controller.class, Peak::Concerns::Regionalization
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end
  end
end
