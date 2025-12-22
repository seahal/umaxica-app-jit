require "test_helper"

module Help::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, RateLimit
      assert_includes controller.class, DefaultUrlOptions
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end
  end
end
