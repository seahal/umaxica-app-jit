# frozen_string_literal: true

require "test_helper"
require "jit/security/turnstile_verifier"

module Jit
  module Security
    class TurnstileVerifierTest < ActiveSupport::TestCase
      def setup
        # Ensure clean state
        TurnstileVerifier.test_mode = false
        TurnstileVerifier.test_response = nil
      end

      def teardown
        TurnstileVerifier.test_mode = false
        TurnstileVerifier.test_response = nil
      end

      test "returns failure on missing token when validation active" do
        # We must disable test_mode to trigger validation logic
        TurnstileVerifier.test_mode = false

        result = TurnstileVerifier.verify(token: "", remote_ip: "127.0.0.1")
        assert_not result["success"]
        assert_equal "missing cf-turnstile-response", result["error"]
      end

      test "returns failure on missing secret when validation active" do
        TurnstileVerifier.test_mode = false

        # Ensure credentials/env return nil for secret key
        ENV.stub(:[], nil) do
          Rails.application.credentials.stub(:dig, nil) do
            result = TurnstileVerifier.verify(token: "token", remote_ip: "127.0.0.1")
            assert_not result["success"]
            assert_equal "missing turnstile secret", result["error"]
          end
        end
      end

      test "returns mock response when test_response set" do
        TurnstileVerifier.test_response = { "success" => true, "mock" => true }
        result = TurnstileVerifier.verify(token: "foo", remote_ip: "127.0.0.1")
        assert result["success"]
        assert result["mock"]
      end

      test "returns success true when test_mode is true" do
        TurnstileVerifier.test_mode = true
        result = TurnstileVerifier.verify(token: "foo", remote_ip: "127.0.0.1")
        assert result["success"]
      end

      test "performs http request when verifying" do
        TurnstileVerifier.test_mode = false

        mock_response = Minitest::Mock.new
        mock_response.expect :body, '{"success": true}'

        Net::HTTP.stub :post_form, mock_response do
          result = TurnstileVerifier.verify(token: "valid", remote_ip: "1.2.3.4", secret_key: "secret")
          assert result["success"]
        end

        mock_response.verify
      end
    end
  end
end
