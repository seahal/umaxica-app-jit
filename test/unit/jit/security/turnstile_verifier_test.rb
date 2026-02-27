# typed: false
# frozen_string_literal: true

require "test_helper"
require "jit/security/turnstile_verifier"

module Jit
  module Security
    class TurnstileVerifierTest < ActiveSupport::TestCase
      # Pure unit test - no database/fixtures needed
      self.use_transactional_tests = false
      self.fixture_table_names = []

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

      # -- mode: :stealth -------------------------------------------------

      test "mode stealth uses TurnstileConfig stealth secret key" do
        TurnstileVerifier.test_mode = false

        mock_response = Minitest::Mock.new
        mock_response.expect :body, '{"success": true}'

        TurnstileConfig.stub :stealth_secret_key, "stealth-secret" do
          Net::HTTP.stub :post_form, mock_response do
            result = TurnstileVerifier.verify(token: "tok", remote_ip: "1.2.3.4", mode: :stealth)

            assert result["success"]
          end
        end

        mock_response.verify
      end

      test "mode stealth returns failure without HTTP when secret is nil" do
        TurnstileVerifier.test_mode = false

        http_called = false

        TurnstileConfig.stub :stealth_secret_key, nil do
          Net::HTTP.stub :post_form, ->(_uri, _params) { http_called = true } do
            result = TurnstileVerifier.verify(token: "tok", remote_ip: "1.2.3.4", mode: :stealth)

            assert_not result["success"]
            assert_equal "missing turnstile secret", result["error"]
          end
        end

        assert_not http_called, "HTTP should not be called when secret is nil"
      end

      test "mode default uses TurnstileConfig default secret key" do
        TurnstileVerifier.test_mode = false

        mock_response = Minitest::Mock.new
        mock_response.expect :body, '{"success": true}'

        TurnstileConfig.stub :default_secret_key, "default-secret" do
          Net::HTTP.stub :post_form, mock_response do
            result = TurnstileVerifier.verify(token: "tok", remote_ip: "1.2.3.4", mode: :default)

            assert result["success"]
          end
        end

        mock_response.verify
      end

      test "no mode preserves legacy secret key resolution" do
        TurnstileVerifier.test_mode = false

        # With no mode, should use the legacy default_secret_key (dig-based)
        # which falls back to ENV
        mock_response = Minitest::Mock.new
        mock_response.expect :body, '{"success": true}'

        Net::HTTP.stub :post_form, mock_response do
          result = TurnstileVerifier.verify(token: "tok", remote_ip: "1.2.3.4", secret_key: "explicit")

          assert result["success"]
        end

        mock_response.verify
      end

      test "explicit secret_key takes priority over mode" do
        TurnstileVerifier.test_mode = false

        mock_response = Minitest::Mock.new
        mock_response.expect :body, '{"success": true}'

        config_called = false
        fake = -> { config_called = true; "should-not-use" }
        TurnstileConfig.stub :stealth_secret_key, fake do
          Net::HTTP.stub :post_form, mock_response do
            result = TurnstileVerifier.verify(
              token: "tok", remote_ip: "1.2.3.4", secret_key: "explicit",
              mode: :stealth,
            )

            assert result["success"]
          end
        end

        assert_not config_called, "TurnstileConfig should not be called when secret_key is explicit"
        mock_response.verify
      end
    end
  end
end
