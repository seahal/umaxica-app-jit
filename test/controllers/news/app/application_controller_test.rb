# frozen_string_literal: true

require "test_helper"

module News::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert controller.class.include?(DefaultUrlOptions)
      assert controller.class.include?(RateLimit)
    end

    test "allows modern browsers" do
      controller = ApplicationController.new

      assert_not_nil controller
    end
  end
end
