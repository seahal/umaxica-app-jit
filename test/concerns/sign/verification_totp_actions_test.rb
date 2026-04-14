# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class VerificationTotpActionsTest < ActiveSupport::TestCase
    class TestController
      include Sign::VerificationTotpActions

      def require_reauth_session!
        @reauth_session_loaded ||= true
      end

      def redirect_if_recent_verification_for_get!
        nil
      end

      def redirect_if_recent_verification_for_post!
        nil
      end

      def require_method_available!(_method)
        true
      end

      def verify_totp!
        @totp_verified ||= false
      end

      def consume_reauth_session!
        @consumed = true
      end

      def render(*, **)
        @rendered = true
      end

      def test_new
        new
      end

      def test_create_success
        @totp_verified = true
        create
      end

      def test_create_failure
        @totp_verified = false
        create
      end

      def consumed?
        @consumed == true
      end

      def rendered?
        @rendered == true
      end
    end

    test "new returns nil when requirements met" do
      controller = TestController.new

      assert_nil controller.test_new
    end

    test "create consumes session when totp verified" do
      controller = TestController.new
      controller.test_create_success

      assert_predicate controller, :consumed?
      assert_not controller.rendered?
    end

    test "create renders new when totp not verified" do
      controller = TestController.new
      controller.test_create_failure

      assert_not controller.consumed?
      assert_predicate controller, :rendered?
    end
  end
end
