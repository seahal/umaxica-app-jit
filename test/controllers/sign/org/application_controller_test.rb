# frozen_string_literal: true

require "test_helper"

module Sign::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, DefaultUrlOptions
      assert_includes controller.class, RateLimit
    end

    test "logged_in_user? returns false" do
      controller = ApplicationController.new

      assert_not controller.send(:logged_in_user?)
    end
  end
end
