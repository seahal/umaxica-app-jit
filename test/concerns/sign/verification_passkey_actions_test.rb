# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class VerificationPasskeyActionsTest < ActiveSupport::TestCase
    class TestController
      include Sign::VerificationPasskeyActions

      def require_reauth_session!
        true
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

      def prepare_passkey_challenge!
        @challenge_prepared = true
      end

      def verify_passkey!
        @passkey_verified
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
        @passkey_verified = true
        create
      end

      def test_create_failure
        @passkey_verified = false
        create
      end

      def challenge_prepared?
        @challenge_prepared == true
      end

      def consumed?
        @consumed == true
      end

      def rendered?
        @rendered == true
      end
    end

    test "new prepares passkey challenge" do
      controller = TestController.new
      controller.test_new

      assert_predicate controller, :challenge_prepared?
    end

    test "create consumes session when passkey verified" do
      controller = TestController.new
      controller.test_create_success

      assert_predicate controller, :consumed?
      assert_not controller.rendered?
    end

    test "create prepares challenge and renders on failure" do
      controller = TestController.new
      controller.test_create_failure

      assert_predicate controller, :challenge_prepared?
      assert_predicate controller, :rendered?
    end
  end
end
