# frozen_string_literal: true

require "test_helper"

module Bff::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert controller.class.include?(RateLimit)
      assert controller.class.include?(DefaultUrlOptions)
      assert controller.class.include?(Bff::Concerns::Regionalization)
    end

    test "logged_in_user? returns false" do
      controller = ApplicationController.new

      assert_equal false, controller.send(:logged_in_user?)
    end
  end
end
