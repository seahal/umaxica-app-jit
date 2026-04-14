# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class VerificationTimingTest < ActiveSupport::TestCase
    class TestToken
      attr_accessor :last_step_up_at, :last_step_up_scope

      def initialize(last_step_up_at: nil, last_step_up_scope: nil)
        @last_step_up_at = last_step_up_at
        @last_step_up_scope = last_step_up_scope
      end
    end

    class TestController
      include Sign::VerificationTiming

      attr_accessor :actor_token

      def initialize(actor_token: nil)
        @actor_token = actor_token
      end

      def test_verification_recent_for_get
        verification_recent_for_get?
      end

      def test_verification_recent_for_post
        verification_recent_for_post?
      end

      def test_verification_recent(scope:, ttl:)
        verification_recent?(scope: scope, ttl: ttl)
      end
    end

    test "returns false when no token" do
      controller = TestController.new

      assert_not controller.test_verification_recent_for_get
    end

    test "returns false when token has no last_step_up_at" do
      controller = TestController.new(actor_token: TestToken.new)

      assert_not controller.test_verification_recent_for_get
    end

    test "returns true when step_up is within TTL" do
      token = TestToken.new(last_step_up_at: 5.minutes.ago)
      controller = TestController.new(actor_token: token)

      assert controller.test_verification_recent_for_get
    end

    test "returns false when step_up is older than TTL" do
      token = TestToken.new(last_step_up_at: 20.minutes.ago)
      controller = TestController.new(actor_token: token)

      assert_not controller.test_verification_recent_for_get
    end

    test "returns true for POST with longer TTL" do
      token = TestToken.new(last_step_up_at: 20.minutes.ago)
      controller = TestController.new(actor_token: token)

      assert controller.test_verification_recent_for_post
    end

    test "returns false when scope does not match" do
      token = TestToken.new(last_step_up_at: 5.minutes.ago, last_step_up_scope: "other")
      controller = TestController.new(actor_token: token)

      assert_not controller.test_verification_recent(scope: "email", ttl: 15.minutes)
    end

    test "returns true when scope matches" do
      token = TestToken.new(last_step_up_at: 5.minutes.ago, last_step_up_scope: "email")
      controller = TestController.new(actor_token: token)

      assert controller.test_verification_recent(scope: "email", ttl: 15.minutes)
    end

    test "VERIFICATION_GET_TTL is 15 minutes" do
      assert_equal 15.minutes, Sign::VerificationTiming::VERIFICATION_GET_TTL
    end

    test "VERIFICATION_POST_TTL is 30 minutes" do
      assert_equal 30.minutes, Sign::VerificationTiming::VERIFICATION_POST_TTL
    end
  end
end
