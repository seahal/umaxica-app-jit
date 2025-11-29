# frozen_string_literal: true

require "test_helper"

module Help::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert controller.class.include?(RateLimit)
      assert controller.class.include?(DefaultUrlOptions)
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end
  end
end
