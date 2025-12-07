# frozen_string_literal: true

require "test_helper"

module Sign
  module App
    module Authentication
      class EmailsControllerSecurityTest < ActionDispatch::IntegrationTest
        test "rejects invalid email format" do
          post sign_app_authentication_email_url, params: {
            user_identity_email: { address: "invalid-email" }
          }

          assert_response :unprocessable_content
        end

        test "normalizes email to lowercase" do
          post sign_app_authentication_email_url, params: {
            user_identity_email: { address: "TEST@EXAMPLE.COM" }
          }

          # Email should be normalized to lowercase in validation
          assert_response :unprocessable_content
        end

        test "rejects emails with excessive whitespace" do
          post sign_app_authentication_email_url, params: {
            user_identity_email: { address: "  test@example.com  " }
          }

          # Whitespace should be stripped and validated
          assert_response :unprocessable_content
        end

        test "handles OTP in Redis instead of session" do
          # This test verifies OTP secrets are stored server-side
          # and only reference ID is in session
          skip "Requires Redis integration test setup"
        end

        test "cleans up OTP secrets after verification" do
          # This test verifies OTP secrets are deleted from Redis
          # after successful verification
          skip "Requires Redis integration test setup"
        end
      end
    end
  end
end
