# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "base64"

module Sign::App::In
  class PasskeysControllerTest < ActionDispatch::IntegrationTest
    setup do
      host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
      @user = users(:one) # Ensure this user has an email in fixtures
      @user_email = UserEmail.create!(user: @user, address: "user@example.com",
                                      user_email_status_id: UserEmailStatus::VERIFIED) unless UserEmail.find_by(user: @user)

      # Setup user passkey for login
      @passkey = UserPasskey.create!(
        user: @user,
        webauthn_id: Base64.urlsafe_encode64("login_id_bytes_12345", padding: false),
        external_id: SecureRandom.uuid,
        public_key: "login_key",
        description: "Login Key",
        user_passkey_status_id: "ACTIVE",
      )

      @telephone = UserTelephone.create!(
        user: @user,
        number: "+15551234567",
        user_identity_telephone_status_id: UserTelephoneStatus::VERIFIED,
        confirm_policy: "1",
        confirm_using_mfa: "1",
      )

      # Mock TRUSTED_ORIGINS
      test_origins = [ "http://sign.app.localhost", "http://sign.org.localhost" ]
      @original_trusted_origins_impl = Webauthn.singleton_class.instance_method(:trusted_origins) rescue nil
      Webauthn.define_singleton_method(:trusted_origins) { test_origins }
    end

    teardown do
      if @original_trusted_origins_impl
        Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins_impl)
      end
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

    test "options returns error if identifier missing" do
      post options_sign_app_in_passkeys_path(ri: "jp"), params: {}

      assert_response :unprocessable_content
      assert_includes response.body, I18n.t("errors.webauthn.identifier_required")
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

    test "options accepts telephone identifier" do
      telephone_value = "+1 (555) 123-4567"

      post options_sign_app_in_passkeys_path(ri: "jp"), params: { identifier: telephone_value }

      assert_response :ok
      json = response.parsed_body
      assert_not_nil json["challenge_id"]
      assert_not_empty json["options"]["allowCredentials"]
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

      # Mock from_get to accept relying_party parameter
      WebAuthn::Credential.stub :from_get, ->(_credential_hash, relying_party: nil) { mock_credential } do
        params = {
          challenge_id: challenge_id,
          credential: {
            id: @passkey.webauthn_id,
            response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" }
          }
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

    # Test relying_party is correctly passed in authentication
    test "verification passes relying_party to from_get" do
      email = UserEmail.find_by(user: @user).address
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { email: email }
      challenge_id = response.parsed_body["challenge_id"]

      # Capture passkey_id in local variable for closure
      passkey_id = @passkey.webauthn_id

      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { Base64.urlsafe_decode64(passkey_id) }
      mock_credential.define_singleton_method(:sign_count) { 1 }
      mock_credential.define_singleton_method(:verify) { |*_args| true }

      # Verify relying_party is passed
      relying_party_received = nil
      mock_from_get = lambda do |_credential_hash, relying_party: nil|
        relying_party_received = relying_party
        mock_credential
      end

      WebAuthn::Credential.stub :from_get, mock_from_get do
        params = {
          challenge_id: challenge_id,
          credential: {
            id: passkey_id,
            response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" }
          }
        }

        post verification_sign_app_in_passkeys_path(ri: "jp"), params: params

        assert_response :ok
        assert_not_nil relying_party_received, "relying_party should be passed to from_get"
        assert_instance_of WebAuthn::RelyingParty, relying_party_received
        assert_includes relying_party_received.allowed_origins, "http://sign.app.localhost"
        assert_equal "sign.app.localhost", relying_party_received.id
      end
    end

    # Test verification fails with invalid credential
    test "verification fails with invalid credential" do
      email = UserEmail.find_by(user: @user).address
      post options_sign_app_in_passkeys_path(ri: "jp"), params: { email: email }
      challenge_id = response.parsed_body["challenge_id"]

      mock_credential = Object.new
      mock_credential.define_singleton_method(:id) { "invalid_id" }
      mock_credential.define_singleton_method(:verify) do |*_args|
        raise WebAuthn::Error, "Invalid credential"
      end

      WebAuthn::Credential.stub :from_get, ->(_credential_hash, relying_party: nil) { mock_credential } do
        params = {
          challenge_id: challenge_id,
          credential: {
            id: "invalid_id",
            response: { clientDataJSON: "e30=", authenticatorData: "e30=", signature: "sig", userHandle: "h" }
          }
        }

        post verification_sign_app_in_passkeys_path(ri: "jp"), params: params

        assert_response :unauthorized
      end
    end
  end
end
