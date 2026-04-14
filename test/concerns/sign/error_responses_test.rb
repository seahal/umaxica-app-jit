# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class ErrorResponsesTest < ActiveSupport::TestCase
    test "handle_not_authorized is defined" do
      assert Sign::ErrorResponses.method_defined?(:handle_not_authorized)
    end

    test "user_not_authorized is aliased to handle_not_authorized" do
      assert_equal :handle_not_authorized, Sign::ErrorResponses.instance_method(:user_not_authorized).original_name
    end

    test "staff_not_authorized is aliased to handle_not_authorized" do
      assert_equal :handle_not_authorized, Sign::ErrorResponses.instance_method(:staff_not_authorized).original_name
    end

    test "handle_csrf_failure is defined" do
      assert Sign::ErrorResponses.method_defined?(:handle_csrf_failure)
    end

    test "handle_application_error is defined" do
      assert Sign::ErrorResponses.method_defined?(:handle_application_error)
    end

    test "activate_error_responses is defined as a class method for including classes" do
      test_controller =
        Class.new do
          include Sign::ErrorResponses
        end

      assert_respond_to test_controller, :activate_error_responses
    end
  end
end
