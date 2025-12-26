# frozen_string_literal: true

require "test_helper"

module Auth::App
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "includes expected concerns" do
      controller = ApplicationController.new

      assert_includes controller.class, ::Authentication::User
      assert_includes controller.class, ::Authorization::User
    end

    test "includes expected concerns 2nd" do
      controller = ApplicationController.new

      assert_includes controller.class, RateLimit
      assert_includes controller.class, DefaultUrlOptions
    end

    test "authenticate_user! allows logged in users" do
      controller = ApplicationController.new
      controller.define_singleton_method(:logged_in?) { true }
      controller.define_singleton_method(:respond_to) { |&block| }

      # Should not raise or call respond_to
      assert_nothing_raised do
        controller.send(:authenticate_user!)
      end
    end
  end
end
