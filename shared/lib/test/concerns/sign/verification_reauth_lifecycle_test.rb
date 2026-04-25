# typed: false
# frozen_string_literal: true

require "test_helper"

class VerificationReauthLifecycleTest < ActiveSupport::TestCase
  class FakeActorToken
    def update!(**)
      true
    end
  end

  class TestController
    include Sign::VerificationReauthLifecycle

    attr_accessor :actor_token

    def initialize(actor_token: nil)
      @actor_token = actor_token
      @reauth_session = { "return_to" => "/dashboard", "scope" => "email" }
    end

    def current_reauth_session
      @reauth_session
    end

    def valid_reauth_session?(session_data)
      session_data.present?
    end

    def handle_invalid_reauth_session!
      false
    end

    def clear_reauth_state!
      @reauth_session = nil
    end

    def verification_model
      mock_model = Object.new
      def mock_model.issue_for_token!(**)
        [OpenStruct.new(expires_at: 1.hour.from_now), "raw-token-123"]
      end
      mock_model
    end

    def set_verification_cookie!(*, **)
      @cookie_set = true
    end

    def create_audit_event!(*, **)
      @audit_created = true
    end

    def current_verification_actor
      OpenStruct.new(id: 1)
    end

    def verification_success_event_id
      1
    end

    def verification_success_notice_key
      "verification_success"
    end

    def verification_success_fallback_path
      "/dashboard"
    end

    def safe_redirect_to(*, **)
      @redirected = true
    end

    def flash
      @flash ||= {}
    end

    def test_require_reauth_session
      require_reauth_session!
    end

    def test_consume_reauth_session
      consume_reauth_session!
    end

    def cookie_set?
      @cookie_set == true
    end

    def audit_created?
      @audit_created == true
    end

    def redirected?
      @redirected == true
    end

    def reauth_session_cleared?
      @reauth_session.nil?
    end
  end

  test "require_reauth_session returns true for valid session" do
    controller = TestController.new

    assert controller.test_require_reauth_session
  end

  test "require_reauth_session returns false for invalid session" do
    controller = TestController.new
    controller.instance_variable_set(:@reauth_session, nil)

    assert_not controller.test_require_reauth_session
  end

  test "consume_reauth_session sets verification cookie" do
    controller = TestController.new
    controller.instance_variable_set(:@actor_token, FakeActorToken.new)
    controller.test_consume_reauth_session

    assert_predicate controller, :cookie_set?
  end

  test "consume_reauth_session creates audit event" do
    controller = TestController.new
    controller.instance_variable_set(:@actor_token, FakeActorToken.new)
    controller.test_consume_reauth_session

    assert_predicate controller, :audit_created?
  end

  test "consume_reauth_session clears reauth state" do
    controller = TestController.new
    controller.instance_variable_set(:@actor_token, FakeActorToken.new)
    controller.test_consume_reauth_session

    assert_predicate controller, :reauth_session_cleared?
  end

  test "consume_reauth_session redirects" do
    controller = TestController.new
    controller.instance_variable_set(:@actor_token, FakeActorToken.new)
    controller.test_consume_reauth_session

    assert_predicate controller, :redirected?
  end
end
