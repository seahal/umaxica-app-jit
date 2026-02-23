# typed: false
# frozen_string_literal: true

require "test_helper"

module Sign
  class WebauthnTest < ActionDispatch::IntegrationTest
    class TestController < ApplicationController
      include Sign::Webauthn

      # Stub methods required by the concern
      attr_accessor :request, :session

      def initialize
        super
        @request = Struct.new(:host, :base_url).new("sign.umaxica.app", "https://sign.umaxica.app")
        @session = {}
      end
    end

    setup do
      @controller = TestController.new
    end

    # Test normalize_webauthn_options_for_json
    test "normalize_webauthn_options_for_json converts symbol keys to string keys" do
      options = WebAuthn::Credential.options_for_create(
        user: { id: "123".b, name: "test", display_name: "Test User" },
        exclude: [],
      )

      normalized = @controller.send(:normalize_webauthn_options_for_json, options)

      assert_kind_of Hash, normalized
      assert normalized.keys.all? { |k| k.is_a?(String) }, "All keys should be strings"
    end

    test "normalize_webauthn_options_for_json produces single challenge key in JSON" do
      options = WebAuthn::Credential.options_for_create(
        user: { id: "123".b, name: "test", display_name: "Test User" },
        exclude: [],
      )

      normalized = @controller.send(:normalize_webauthn_options_for_json, options)
      json_output = normalized.to_json

      # Count "challenge" keys in JSON output
      challenge_count = json_output.scan(/"challenge"/).count
      assert_equal 1, challenge_count, "JSON should contain exactly one 'challenge' key, found #{challenge_count}"
    end

    test "normalize_webauthn_options_for_json encodes user.id as Base64URL" do
      # Test with numeric string ID (the bug case)
      options = WebAuthn::Credential.options_for_create(
        user: { id: "980190962".b, name: "test@example.com", display_name: "test@example.com" },
        exclude: [],
      )

      normalized = @controller.send(:normalize_webauthn_options_for_json, options)
      user_id = normalized["user"]["id"]

      # Should be Base64URL encoded
      assert_kind_of String, user_id
      assert_match(/\A[A-Za-z0-9_-]+\z/, user_id, "user.id should be Base64URL format")

      # Should have valid padding when decoded
      padding_needed = (4 - (user_id.length % 4)) % 4
      assert_operator padding_needed, :<=, 2,
                      "user.id should have valid Base64URL padding (0-2), but would need #{padding_needed}"

      # Should decode back to original
      decoded = Base64.urlsafe_decode64(user_id)
      assert_equal "980190962", decoded
    end

    test "normalize_webauthn_options_for_json encodes challenge as Base64URL" do
      options = WebAuthn::Credential.options_for_create(
        user: { id: "123".b, name: "test", display_name: "Test" },
        exclude: [],
      )

      normalized = @controller.send(:normalize_webauthn_options_for_json, options)
      challenge = normalized["challenge"]

      assert_kind_of String, challenge
      assert_match(/\A[A-Za-z0-9_-]+\z/, challenge, "challenge should be Base64URL format")

      # Verify valid padding
      padding_needed = (4 - (challenge.length % 4)) % 4
      assert_operator padding_needed, :<=, 2, "challenge should have valid Base64URL padding"
    end

    test "normalize_webauthn_options_for_json handles excludeCredentials" do
      # Create options with excluded credentials
      options = WebAuthn::Credential.options_for_create(
        user: { id: "123".b, name: "test", display_name: "Test" },
        exclude: ["credential-id-1", "credential-id-2"],
      )

      normalized = @controller.send(:normalize_webauthn_options_for_json, options)

      assert_kind_of Array, normalized["excludeCredentials"]
      normalized["excludeCredentials"].each do |cred|
        assert_kind_of String, cred["id"]
        assert_match(/\A[A-Za-z0-9_-]+\z/, cred["id"], "credential id should be Base64URL format")
      end
    end

    test "normalize_webauthn_options_for_json handles allowCredentials" do
      # Create options with allowed credentials
      options = WebAuthn::Credential.options_for_get(
        allow: ["credential-id-1", "credential-id-2"],
        user_verification: "preferred",
      )

      normalized = @controller.send(:normalize_webauthn_options_for_json, options)

      assert_kind_of Array, normalized["allowCredentials"]
      normalized["allowCredentials"].each do |cred|
        assert_kind_of String, cred["id"]
        assert_match(/\A[A-Za-z0-9_-]+\z/, cred["id"], "credential id should be Base64URL format")
      end
    end

    test "normalize_webauthn_id handles various input types" do
      # String already in Base64URL format
      result = @controller.send(:normalize_webauthn_id, "abc123_-")
      assert_equal "abc123_-", result

      # String that looks like Base64URL but is actually raw ASCII letters
      # (will be returned as-is since it matches /\A[A-Za-z0-9_-]+\z/)
      result = @controller.send(:normalize_webauthn_id, "test")
      assert_equal "test", result

      # Binary string with non-Base64URL chars (e.g. with null bytes)
      binary_with_null = "test\x00data".b
      result = @controller.send(:normalize_webauthn_id, binary_with_null)
      assert_equal Base64.urlsafe_encode64(binary_with_null, padding: false), result

      # Array of bytes
      result = @controller.send(:normalize_webauthn_id, [116, 101, 115, 116])
      assert_equal Base64.urlsafe_encode64("test", padding: false), result

      # Integer
      result = @controller.send(:normalize_webauthn_id, 12_345)
      assert_kind_of String, result
      assert_match(/\A[A-Za-z0-9_-]+\z/, result)

      # Nil
      result = @controller.send(:normalize_webauthn_id, nil)
      assert_nil result
    end

    test "with_webauthn_config sets and restores configuration" do
      original_origins = WebAuthn.configuration.allowed_origins
      original_rp_id = WebAuthn.configuration.rp_id

      @controller.send(:with_webauthn_config) do
        # Inside block, config should be set
        assert_equal ["https://sign.umaxica.app"], WebAuthn.configuration.allowed_origins
        assert_equal "sign.umaxica.app", WebAuthn.configuration.rp_id
      end

      # After block, config should be restored (may be nil in test env)
      if original_origins.nil?
        assert_nil WebAuthn.configuration.allowed_origins
      else
        assert_equal original_origins, WebAuthn.configuration.allowed_origins
      end

      if original_rp_id.nil?
        assert_nil WebAuthn.configuration.rp_id
      else
        assert_equal original_rp_id, WebAuthn.configuration.rp_id
      end
    end

    test "with_webauthn_config restores configuration even on error" do
      original_origins = WebAuthn.configuration.allowed_origins
      original_rp_id = WebAuthn.configuration.rp_id

      assert_raises(RuntimeError) do
        @controller.send(:with_webauthn_config) do
          raise "Test error"
        end
      end

      # Config should still be restored after error (may be nil in test env)
      if original_origins.nil?
        assert_nil WebAuthn.configuration.allowed_origins
      else
        assert_equal original_origins, WebAuthn.configuration.allowed_origins
      end

      if original_rp_id.nil?
        assert_nil WebAuthn.configuration.rp_id
      else
        assert_equal original_rp_id, WebAuthn.configuration.rp_id
      end
    end
  end
end
