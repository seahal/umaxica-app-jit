# frozen_string_literal: true

require "test_helper"

module Sign::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert controller.class.include?(DefaultUrlOptions)
      assert controller.class.include?(RateLimit)
    end

    test "logged_in_user? returns false" do
      controller = ApplicationController.new

      assert_equal false, controller.send(:logged_in_user?)
    end

    test "logged_in_staff? returns false" do
      controller = ApplicationController.new

      assert_equal false, controller.send(:logged_in_staff?)
    end

    test "logged_in? returns false when no one is logged in" do
      controller = ApplicationController.new

      assert_equal false, controller.send(:logged_in?)
    end
  end
end
