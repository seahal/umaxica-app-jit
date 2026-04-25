# typed: false
# frozen_string_literal: true

require "test_helper"

module Auth
  class AuthorizationHeaderTest < ActiveSupport::TestCase
    class MockRequest
      attr_accessor :authorization_header

      def initialize(authorization: nil)
        @authorization_header = authorization
      end

      def authorization
        @authorization_header
      end

      def respond_to?(method, *)
        method == :authorization || super
      end

      def headers
        {}
      end
    end

    test "bearer_token extracts token from Bearer header" do
      request = MockRequest.new(authorization: "Bearer abc123")

      assert_equal "abc123", AuthorizationHeader.bearer_token(request)
    end

    test "bearer_token extracts token from Token header" do
      request = MockRequest.new(authorization: "Token xyz789")

      assert_equal "xyz789", AuthorizationHeader.bearer_token(request)
    end

    test "bearer_token returns nil for missing header" do
      request = MockRequest.new(authorization: nil)

      assert_nil AuthorizationHeader.bearer_token(request)
    end

    test "bearer_token returns nil for blank header" do
      request = MockRequest.new(authorization: "")

      assert_nil AuthorizationHeader.bearer_token(request)
    end

    test "bearer_token returns nil for malformed header" do
      request = MockRequest.new(authorization: "InvalidFormat")

      assert_nil AuthorizationHeader.bearer_token(request)
    end

    test "normalize_scheme capitalizes bearer" do
      assert_equal "Bearer abc", AuthorizationHeader.send(:normalize_scheme, "bearer abc")
    end

    test "normalize_scheme capitalizes token" do
      assert_equal "Token xyz", AuthorizationHeader.send(:normalize_scheme, "token xyz")
    end

    test "normalize_scheme leaves already capitalized scheme" do
      assert_equal "Bearer abc", AuthorizationHeader.send(:normalize_scheme, "Bearer abc")
    end

    test "normalize_scheme does not modify non-token schemes" do
      assert_equal "Basic abc", AuthorizationHeader.send(:normalize_scheme, "Basic abc")
    end
  end
end
