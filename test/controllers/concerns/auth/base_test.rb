# frozen_string_literal: true

require "test_helper"

module Auth
  class BaseTest < ActiveSupport::TestCase
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
    end

    test "REFRESH_COOKIE_KEY is defined" do
      assert_kind_of String, Auth::Base::REFRESH_COOKIE_KEY
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
