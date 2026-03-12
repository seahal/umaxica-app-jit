# typed: false
# frozen_string_literal: true

require "test_helper"

module Auth
  class BaseTest < ActiveSupport::TestCase
    class HeaderKeyHarness
      include Auth::Base

      attr_accessor :actor_type

      def resource_type
        actor_type
      end

      def resource_class = User

      def token_class = UserToken

      def audit_class = UserActivity

      def resource_foreign_key = :user_id

      def sign_in_url_with_return(_return_to) = "/sign/in"

      def am_i_user? = false

      def am_i_staff? = false

      def am_i_owner? = false
    end

    test "VALID_POLICIES constant is defined" do
      assert_equal %i(public_strict auth_required guest_only), Auth::Base::VALID_POLICIES
    end

    test "AUDIT_EVENTS constant is defined" do
      assert Auth::Base::AUDIT_EVENTS.key?(:logged_in)
      assert Auth::Base::AUDIT_EVENTS.key?(:logged_out)
      assert Auth::Base::AUDIT_EVENTS.key?(:login_failed)
      assert Auth::Base::AUDIT_EVENTS.key?(:token_refreshed)
    end

    test "ACCESS_COOKIE_KEY is defined" do
      assert_kind_of String, Auth::Base::ACCESS_COOKIE_KEY
      assert_equal "jit_auth_access", Auth::Base::ACCESS_COOKIE_KEY
    end

    test "REFRESH_COOKIE_KEY is defined" do
      assert_kind_of String, Auth::Base::REFRESH_COOKIE_KEY
      assert_equal "jit_auth_refresh", Auth::Base::REFRESH_COOKIE_KEY
    end

    test "DEVICE_COOKIE_KEY is defined" do
      assert_kind_of String, Auth::Base::DEVICE_COOKIE_KEY
      assert_equal "jit_auth_device_id", Auth::Base::DEVICE_COOKIE_KEY
    end

    test "test_header_key resolves actor specific keys" do
      harness = HeaderKeyHarness.new

      harness.actor_type = "user"

      assert_equal "X-TEST-CURRENT-USER", harness.send(:test_header_key)

      harness.actor_type = "staff"

      assert_equal "X-TEST-CURRENT-STAFF", harness.send(:test_header_key)

      harness.actor_type = "viewer"

      assert_equal "X-TEST-CURRENT-VIEWER", harness.send(:test_header_key)

      harness.actor_type = "unknown"

      assert_equal "X-TEST-CURRENT-RESOURCE", harness.send(:test_header_key)
    end

    test "device cookie is managed through dedicated helpers only" do
      source = Rails.root.join("app/controllers/concerns/auth/base.rb").read

      assert_includes source, "def set_device_id_cookie!"
      assert_includes source, "def clear_device_id_cookie!"
      assert_includes source, "def read_device_id_cookie"
      assert_no_match(/cookies\[DEVICE_COOKIE_KEY\]/, source)
      assert_no_match(/cookies\.delete\s+DEVICE_COOKIE_KEY/, source)
      assert_no_match(/cookies\.delete\(DEVICE_COOKIE_KEY/, source)
    end

    test "ACCESS_TOKEN_TTL is defined" do
      assert_kind_of ActiveSupport::Duration, Auth::Base::ACCESS_TOKEN_TTL
    end

    test "REFRESH_TOKEN_TTL is defined" do
      assert_kind_of ActiveSupport::Duration, Auth::Base::REFRESH_TOKEN_TTL
    end

    test "Token class has JWT_ALGORITHM constant" do
      assert_equal "ES384", Auth::Base::Token::JWT_ALGORITHM
    end

    test "Token.extract_subject returns nil for nil payload" do
      assert_nil Auth::Base::Token.extract_subject(nil)
    end

    test "VALID_ACTOR_TYPES constant is defined" do
      assert_equal %w(user staff), Auth::Base::VALID_ACTOR_TYPES
    end

    test "Token.extract_act returns nil for nil payload" do
      assert_nil Auth::Base::Token.extract_act(nil)
    end

    test "Token.extract_type returns nil for nil payload" do
      assert_nil Auth::Base::Token.extract_type(nil)
    end

    test "Token.extract_session_id returns nil for nil payload" do
      assert_nil Auth::Base::Token.extract_session_id(nil)
    end

    test "Token.extract_jti returns nil for nil payload" do
      assert_nil Auth::Base::Token.extract_jti(nil)
    end

    test "JwtConfiguration.issuer returns string" do
      issuer = Auth::Base::JwtConfiguration.issuer

      assert_kind_of String, issuer
    end

    test "JwtConfiguration.audiences returns array" do
      audiences = Auth::Base::JwtConfiguration.audiences

      assert_kind_of Array, audiences
    end

    test "JwtConfiguration.leeway_seconds returns integer" do
      assert_kind_of Integer, Auth::Base::JwtConfiguration.leeway_seconds
    end

    test "MissingPolicyError is a StandardError" do
      assert_operator Auth::Base::MissingPolicyError, :<, StandardError
    end

    test "InvalidPolicyError is a StandardError" do
      assert_operator Auth::Base::InvalidPolicyError, :<, StandardError
    end

    test "SkipNotAllowedError is a StandardError" do
      assert_operator Auth::Base::SkipNotAllowedError, :<, StandardError
    end
  end
end
