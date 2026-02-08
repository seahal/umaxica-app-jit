# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "base64"

module Sign::App::In
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    fixtures :users, :user_statuses, :user_email_statuses, :user_telephone_statuses

    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      @user = users(:one) # Ensure this user has an email in fixtures
      @user_email = UserEmail.create!(user: @user, address: "user@example.com") unless UserEmail.find_by(user: @user)
      @user_telephone = UserTelephone.create!(user: @user, number: "+819012345678") unless UserTelephone.find_by(user: @user)

      # Setup user passkey for login
      @passkey = UserPasskey.create!(
        user: @user,
        webauthn_id: Base64.urlsafe_encode64("login_id_bytes_12345", padding: false),
        external_id: SecureRandom.uuid,
        public_key: "login_key",
        description: "Login Key",
        status_id: UserPasskeyStatus::ACTIVE,
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

    # Case F-1: Identifier does not exist
    test "options returns error if identifier not found" do
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: "unknown@example.com" }

      assert_response :unprocessable_content
      assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
    end

    # Case F-2: Identifier exists but no passkey
    test "options returns error if no passkeys" do
      user_no_passkey = users(:two)
      user_no_passkey_email = UserEmail.create!(user: user_no_passkey, address: "nopasskey@example.com")

      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: user_no_passkey_email.address }

      assert_response :unprocessable_content
      assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
    end

    test "options returns challenge and allowCredentials for email identifier" do
      email = UserEmail.find_by(user: @user).address

      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: email }

      assert_response :ok
      json = response.parsed_body

      assert_not_nil json["challenge_id"]
      options = json["options"]
      assert_not_empty options["allowCredentials"]

      Rails.logger.debug { "DEBUG: allowCredentials = #{options["allowCredentials"].inspect}" }
      Rails.logger.debug { "DEBUG: allowCredentials = #{options["allowCredentials"].inspect}" }
      Rails.logger.debug { "DEBUG: passkey_id = #{@passkey.webauthn_id}" }

      # Verify allowCredentials contains our passkey ID
      match = options["allowCredentials"].any? { |c| c["id"] == @passkey.webauthn_id }
      assert match, "Expected allowCredentials to contain #{@passkey.webauthn_id}"

      # Case F-4: Challenge saved with correct purpose
      assert_not_nil session[:passkey_challenges][json["challenge_id"]]
      assert_equal "authentication", session[:passkey_challenges][json["challenge_id"]]["purpose"]
    end

    test "options returns challenge and allowCredentials for telephone identifier" do
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: @user_telephone.number }

      assert_response :ok
      json = response.parsed_body
      assert_not_nil json["challenge_id"]
      assert_not_empty json.dig("options", "allowCredentials")
    end

    # Case F-3b: JSON response format validation for authentication options (regression test)
    test "options returns valid Base64URL encoded challenge" do
      email = UserEmail.find_by(user: @user).address

      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: email }

      assert_response :ok
      json = response.parsed_body
      options = json["options"]

      # Verify challenge is Base64URL encoded
      challenge = options["challenge"]
      assert_match(/\A[A-Za-z0-9_-]+\z/, challenge, "challenge should be Base64URL format")
      padding_needed = (4 - (challenge.length % 4)) % 4
      assert_operator padding_needed, :<=, 2,
                      "challenge should have valid Base64URL padding (0-2 chars), but would need #{padding_needed}"

      # Verify no duplicate keys in JSON
      json_string = response.body
      challenge_count = json_string.scan(/"challenge"/).count
      assert_equal 1, challenge_count, "JSON should contain exactly one 'challenge' key (found #{challenge_count})"

      # Verify allowCredentials IDs are properly encoded
      options["allowCredentials"].each_with_index do |credential, index|
        cred_id = credential["id"]
        assert_match(/\A[A-Za-z0-9_-]+\z/, cred_id, "allowCredentials[#{index}].id should be Base64URL format")
      end
    end

    # Case G-1: Verification success
    test "verification logs user in on success" do
      assert_not_nil @passkey, "Passkey must exist"
      # Get challenge
      email = UserEmail.find_by(user: @user).address
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: email }
      explanation = response.parsed_body
      challenge_id = explanation["challenge_id"]

      # Mock WebAuthn verification
      mock_credential = Object.new
      passkey_id = @passkey.webauthn_id
      mock_credential.define_singleton_method(:id) { passkey_id }
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
