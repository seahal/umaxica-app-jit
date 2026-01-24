# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "base64"

module Sign::App::In
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      @user = users(:one) # Ensure this user has an email in fixtures
      @user_email = UserEmail.create!(user: @user, address: "user@example.com") unless UserEmail.find_by(user: @user)

      # Setup user passkey for login
      @passkey = UserPasskey.create!(
        user: @user,
        webauthn_id: Base64.urlsafe_encode64("login_id_bytes_12345", padding: false),
        external_id: SecureRandom.uuid,
        public_key: "login_key",
        description: "Login Key",
        user_passkey_status_id: "ACTIVE",
      )

      # Mock TRUSTED_ORIGINS
      @original_trusted_origins = Webauthn.method(:trusted_origins)
      Webauthn.define_singleton_method(:trusted_origins) { ["http://sign.app.localhost", "http://sign.org.localhost"] }
    end

    teardown do
      Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
    end

    test "should get new" do
      get new_sign_app_in_passkey_path(ri: "jp")

      assert_response :success
    end

    # Case F-1: Email does not exist
    test "options returns error if email not found" do
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { email: "unknown@example.com" }

      assert_response :unprocessable_content
      assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
    end

    # Case F-2: Email exists but no passkey
    test "options returns error if no passkeys" do
      user_no_passkey = users(:two)
      user_no_passkey_email = UserEmail.create!(user: user_no_passkey, address: "nopasskey@example.com")

      post options_sign_app_in_passkeys_path(ri: "jp"), params: { email: user_no_passkey_email.address }

      assert_response :unprocessable_content
      assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
    end

    # Case F-3: Email exists and has passkey
    test "options returns challenge and allowCredentials" do
      email = UserEmail.find_by(user: @user).address

      post options_sign_app_in_passkeys_path(ri: "jp"), params: { email: email }

      assert_response :ok
      json = response.parsed_body

      assert_not_nil json["challenge_id"]
      options = json["options"]
      assert_not_empty options["allowCredentials"]

      Rails.logger.debug { "DEBUG: allowCredentials = #{options["allowCredentials"].inspect}" }
      Rails.logger.debug { "DEBUG: allowCredentials = #{options["allowCredentials"].inspect}" }
      Rails.logger.debug { "DEBUG: passkey_id = #{@passkey.webauthn_id}" }

      # Verify allowCredentials contains our passkey ID (encoded or raw)
      encoded_id = Base64.urlsafe_encode64(@passkey.webauthn_id, padding: false)
      match = options["allowCredentials"].any? { |c| c["id"] == encoded_id || c["id"] == @passkey.webauthn_id }
      assert match, "Expected allowCredentials to contain #{@passkey.webauthn_id} or #{encoded_id}"

      # Case F-4: Challenge saved with correct purpose
      assert_not_nil session[:passkey_challenges][json["challenge_id"]]
      assert_equal "authentication", session[:passkey_challenges][json["challenge_id"]]["purpose"]
    end

    # Case G-1: Verification success
    test "verification logs user in on success" do
      assert_not_nil @passkey, "Passkey must exist"
      # Get challenge
      email = UserEmail.find_by(user: @user).address
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { email: email }
      explanation = response.parsed_body
      challenge_id = explanation["challenge_id"]

      # Mock WebAuthn verification
      mock_credential = Object.new
      passkey_id = @passkey.webauthn_id
      mock_credential.define_singleton_method(:id) { Base64.urlsafe_decode64(passkey_id) }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      WebAuthn::Credential.stub :from_get, mock_credential do
        params = {
          challenge_id: challenge_id,
          credential: {
            id: @passkey.webauthn_id,
            response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" },
          },
        }

        # Should log in
        post verification_sign_app_in_passkeys_path(ri: "jp"), params: params

        assert_response :ok
        json = response.parsed_body
        assert_equal "ok", json["status"]
        assert_not_nil json["access_token"]

        # Challenge verification updates sign count
        assert_equal 1, @passkey.reload.sign_count
      end
    end
  end
end
