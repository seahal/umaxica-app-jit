# frozen_string_literal: true

require "test_helper"

module Sign::Org
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    setup do
      @controller = Sign::Org::ApplicationController.new
      @controller.request = ActionDispatch::TestRequest.create
      @controller.response = ActionDispatch::TestResponse.new
      @staff = staffs(:one)
    end

    test "includes expected concerns" do
      assert_includes @controller.class, DefaultUrlOptions
      assert_includes @controller.class, RateLimit
    end

    test "logged_in_user? returns false" do
      assert_not @controller.send(:logged_in_user?)
    end

    test "authenticate_staff! allows access when staff is logged in" do
      # Mock current_staff
      @controller.instance_variable_set(:@current_staff, @staff)
      # Should not raise or redirect
      assert_nothing_raised do
        @controller.send(:authenticate_staff!)
      end
    end
  end
end
