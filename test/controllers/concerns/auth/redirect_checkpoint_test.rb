# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthRedirectCheckpointTest < ActiveSupport::TestCase
  class RedirectHarness
    include Auth::Base

    attr_accessor :session_data, :params_data, :request_obj, :performed

    def initialize
      @session_data = {}
      @params_data = {}
      @request_obj = MockRequest.new
      @performed = false
    end

    def session
      @session_data
    end

    def params
      @params_data
    end

    def request
      @request_obj
    end

    def performed?
      @performed
    end

    def redirect_to(*_args)
      @performed = true
    end

    def render(*_args)
      @performed = true
    end

    def resource_type
      "user"
    end

    def resource_class
      User
    end

    def token_class
      UserToken
    end

    def audit_class
      UserActivity
    end

    def resource_foreign_key
      :user_id
    end

    def sign_in_url_with_return(_return_to)
      "/sign/in"
    end

    def am_i_user?
      false
    end

    def am_i_staff?
      false
    end

    def am_i_owner?
      false
    end
  end

  class MockRequest
    attr_accessor :host, :remote_ip, :user_agent, :request_id, :fullpath

    def initialize
      @host = "example.com"
      @remote_ip = "127.0.0.1"
      @user_agent = "TestAgent"
      @request_id = "test-123"
      @fullpath = "/test"
    end

    def format
      MockFormat.new
    end

    def headers
      {}
    end
  end

  class MockFormat
    def json?
      false
    end

    def html?
      true
    end
  end

  setup do
    @harness = RedirectHarness.new
  end

  test "DEFAULT_RD_SESSION_KEY is defined" do
    assert_includes Auth::Base::DEFAULT_RD_SESSION_KEY.to_s, "rd"
  end

  test "CHECKPOINT_SESSION_KEY is defined" do
    assert_equal :in_checkpoint, Auth::Base::CHECKPOINT_SESSION_KEY
  end

  test "CHECKPOINT_TIMEOUT is 2 hours" do
    assert_equal 2.hours, Auth::Base::CHECKPOINT_TIMEOUT
  end

  test "preserve_redirect_parameter stores rd in session" do
    @harness.params_data[Auth::IoKeys::Params::RD] = "/dashboard"
    result = @harness.preserve_redirect_parameter

    assert_equal "/dashboard", result
    assert_equal "/dashboard", @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY]
  end

  test "preserve_redirect_parameter returns nil when no rd param" do
    result = @harness.preserve_redirect_parameter

    assert_nil result
    assert_nil @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY]
  end

  test "retrieve_redirect_parameter returns and clears session value" do
    @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY] = "/dashboard"
    result = @harness.retrieve_redirect_parameter

    assert_equal "/dashboard", result
    assert_nil @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY]
  end

  test "retrieve_redirect_parameter falls back to params" do
    @harness.params_data[Auth::IoKeys::Params::RD] = "/from-params"
    result = @harness.retrieve_redirect_parameter

    assert_equal "/from-params", result
  end

  test "peek_redirect_parameter returns without clearing" do
    @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY] = "/dashboard"
    result = @harness.peek_redirect_parameter

    assert_equal "/dashboard", result
    assert_equal "/dashboard", @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY]
  end

  test "build_redirect_params includes rd when present" do
    @harness.session[Auth::Base::DEFAULT_RD_SESSION_KEY] = "/dashboard"
    result = @harness.build_redirect_params(:notice, "Success")

    assert_equal "Success", result[:notice]
    assert_equal "/dashboard", result[Auth::IoKeys::Params::RD]
  end

  test "build_notice_params creates notice hash" do
    result = @harness.build_notice_params("Success")

    assert_equal "Success", result[:notice]
  end

  test "build_alert_params creates alert hash" do
    result = @harness.build_alert_params("Warning")

    assert_equal "Warning", result[:alert]
  end

  test "issue_checkpoint! sets checkpoint in session" do
    freeze_time do
      @harness.issue_checkpoint!(kind: "mfa", state: "pending")

      checkpoint = @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY]
      assert_equal "mfa", checkpoint["kind"]
      assert_equal "pending", checkpoint["state"]
      assert_equal Time.current.to_i, checkpoint["issued_at"]
    end
  end

  test "checkpoint_state returns nil when no checkpoint" do
    assert_nil @harness.checkpoint_state
  end

  test "checkpoint_state returns hash with indifferent access" do
    @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY] = { "kind" => "mfa", "state" => "pending" }
    result = @harness.checkpoint_state

    assert_equal "mfa", result[:kind]
    assert_equal "pending", result[:state]
  end

  test "checkpoint_active? returns false when no checkpoint" do
    assert_not @harness.checkpoint_active?
  end

  test "checkpoint_expired? returns true for old checkpoint" do
    old_time = (3.hours.ago).to_i
    @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY] = {
      "issued_at" => old_time,
      "kind" => "mfa",
      "state" => "pending",
    }

    assert_predicate @harness, :checkpoint_expired?
  end

  test "consume_checkpoint! removes checkpoint from session" do
    @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY] = { "kind" => "mfa" }
    @harness.consume_checkpoint!

    assert_nil @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY]
  end

  test "refresh_checkpoint_dimension! updates issued_at and state" do
    old_time = 1.hour.ago.to_i
    @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY] = {
      "issued_at" => old_time,
      "kind" => "mfa",
      "state" => "pending",
    }

    travel_to(1.second.from_now)
    @harness.refresh_checkpoint_dimension!(state: "updated")
    checkpoint = @harness.session[Auth::Base::CHECKPOINT_SESSION_KEY]

    assert_operator checkpoint["issued_at"], :>, old_time
    assert_equal "updated", checkpoint["state"]
  end
end
