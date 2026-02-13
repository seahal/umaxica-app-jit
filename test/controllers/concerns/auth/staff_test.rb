# frozen_string_literal: true

require "test_helper"

class TestAuthStaffController < ApplicationController
  include Auth::Staff
end

module Auth
  class AuthStaffConcernTest < ActionDispatch::IntegrationTest
    setup do
      @controller = TestAuthStaffController.new
    end

    test "Staff concern includes Auth::Base" do
      assert_includes TestAuthStaffController.ancestors, Auth::Base
    end

    test "constants are inherited from Auth::Base" do
      assert_equal Auth::Base::ACCESS_COOKIE_KEY, Auth::Staff::ACCESS_COOKIE_KEY
      assert_equal Auth::Base::REFRESH_COOKIE_KEY, Auth::Staff::REFRESH_COOKIE_KEY
      assert_equal Auth::Base::AUDIT_EVENTS, Auth::Staff::AUDIT_EVENTS
    end

    test "resource_class returns Staff" do
      assert_equal ::Staff, @controller.send(:resource_class)
    end

    test "token_class returns StaffToken" do
      assert_equal StaffToken, @controller.send(:token_class)
    end

    test "audit_class returns StaffActivity" do
      assert_equal ::StaffActivity, @controller.send(:audit_class)
    end

    test "resource_type returns staff" do
      assert_equal "staff", @controller.send(:resource_type)
    end

    test "resource_foreign_key returns staff_id" do
      assert_equal :staff_id, @controller.send(:resource_foreign_key)
    end

    test "test_header_key returns X-TEST-CURRENT-STAFF" do
      assert_equal "X-TEST-CURRENT-STAFF", @controller.send(:test_header_key)
    end

    test "am_i_user? returns false" do
      assert_not @controller.am_i_user?
    end

    test "am_i_staff? returns true" do
      assert_predicate @controller, :am_i_staff?
    end

    test "am_i_owner? returns false" do
      assert_not @controller.am_i_owner?
    end

    test "active_staff? method exists" do
      assert_respond_to @controller, :active_staff?
    end
  end
end
