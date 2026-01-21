# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

module Sign::App::In::Passkey
  class AuthenticationFlowTest < ActionDispatch::IntegrationTest
    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      @user = users(:one)
      # Setup a passkey for the user
      @passkey = UserPasskey.create!(
        user: @user,
        webauthn_id: "credential-12345",
        public_key: "dummy-public-key",
        sign_count: 10,
        description: "Test Passkey",
        external_id: SecureRandom.uuid,
      )
    end

    test "should generate authentication options and store challenge in session" do
      post sign_app_in_passkey_options_url(ri: "jp"), as: :json

      assert_response :success
      json_response = response.parsed_body
      assert_not_nil json_response["challenge"]

      # Verify session storage
      assert_not_nil session[:webauthn]
      assert_equal json_response["challenge"], session[:webauthn]["challenge"]
      assert_equal "authentication", session[:webauthn]["purpose"]
      assert_equal "sign/app/in/passkey", session[:webauthn]["scope"]
    end

    test "should verify valid credential and log in" do
      # 1. Get options to setup session
      post sign_app_in_passkey_options_url(ri: "jp"), as: :json
      session[:webauthn]["challenge"]

      # 2. Mock WebAuthn verification
      mock_credential = OpenStruct.new(
        id: @passkey.webauthn_id,
        sign_count: 11,
      )

      # We need to verify signature and return expected result
      def mock_credential.verify(_challenge, **)
        true
      end

      WebAuthn::Credential.stub :from_get, mock_credential do
        post sign_app_in_passkey_verification_url(ri: "jp"), params: {
          credential: {
            id: @passkey.webauthn_id,
            rawId: @passkey.webauthn_id,
            type: "public-key",
            response: {
              clientDataJSON: "dummy",
              authenticatorData: "dummy",
              signature: "dummy",
              userHandle: @user.public_id,
            },
          },
        }, as: :json
      end

      assert_response :success
      json_response = response.parsed_body
      assert_equal "ok", json_response["status"]
      assert_not_nil json_response["access_token"]

      # 3. Verify side effects
      assert_nil session[:webauthn] # consumed
      @passkey.reload
      assert_equal 11, @passkey.sign_count # updated
    end

    test "should fail verification with invalid challenge" do
      # 1. No options call (no session)

      post sign_app_in_passkey_verification_url(ri: "jp"), params: {
        credential: { id: "foo" },
      }, as: :json

      assert_response :bad_request
      json_response = response.parsed_body
      assert_equal I18n.t("errors.webauthn.challenge_invalid"), json_response["error"]
    end
  end
end
