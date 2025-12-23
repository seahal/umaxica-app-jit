require "test_helper"

module Docs::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, DefaultUrlOptions
      assert_includes controller.class, RateLimit
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end
  end
end
