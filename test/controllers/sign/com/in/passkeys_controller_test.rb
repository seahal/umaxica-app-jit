# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::Com::In::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_email_statuses, :user_telephone_statuses

  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @origin_headers = { "HTTP_ORIGIN" => "http://#{@host}", "Origin" => "http://#{@host}" }.freeze
    Jit::Security::TurnstileVerifier.test_mode = true
    Jit::Security::TurnstileVerifier.test_response = { "success" => true }

    @user = create_verified_user_with_email(email_address: "com_passkey_test@example.com")
    @user.user_telephones.create!(
      number: "+819012345678",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: Base64.urlsafe_encode64("com_login_id_bytes_12345", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "login_key",
      description: "Login Key",
      status_id: UserPasskeyStatus::ACTIVE,
    )

    @original_trusted_origins = Webauthn.method(:trusted_origins)
    Webauthn.define_singleton_method(:trusted_origins) { ["http://sign.app.localhost", "http://#{@host}"] }
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins)
    Jit::Security::TurnstileVerifier.test_mode = false
    Jit::Security::TurnstileVerifier.test_response = nil
  end

  test "should get new" do
    get new_sign_com_in_passkey_path(ri: "jp"), headers: @origin_headers

    assert_response :success
  end

  test "options returns challenge for known identifier" do
    Sign::Com::In::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      post options_sign_com_in_passkeys_path(ri: "jp"),
           params: { identifier: @user.user_emails.first.address },
           headers: @origin_headers
    end

    assert_response :ok
    json = response.parsed_body

    assert_not_nil json["challenge_id"]
    assert_equal "authentication", session[:passkey_challenges][json["challenge_id"]]["purpose"]
    assert_equal @user.id, session[:passkey_challenges][json["challenge_id"]]["user_id"]
  end

  test "options returns error when identifier is unknown" do
    Sign::Com::In::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      post options_sign_com_in_passkeys_path(ri: "jp"),
           params: { identifier: "missing@example.com" },
           headers: @origin_headers
    end

    assert_response :unprocessable_content
    assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
  end

  test "options returns error when identifier has no passkeys" do
    user_without_passkey = create_verified_user_with_email(email_address: "no_passkey@example.com")
    user_without_passkey.user_telephones.create!(
      number: "+819012300000",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    Sign::Com::In::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      post options_sign_com_in_passkeys_path(ri: "jp"),
           params: { identifier: user_without_passkey.user_emails.first.address },
           headers: @origin_headers
    end

    assert_response :unprocessable_content
    assert_includes response.body, I18n.t("errors.webauthn.no_passkeys_available")
  end

  test "verification logs user in on success" do
    Sign::Com::In::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      post options_sign_com_in_passkeys_path(ri: "jp"),
           params: { identifier: @user.user_emails.first.address },
           headers: @origin_headers
    end
    challenge_id = response.parsed_body["challenge_id"]

    mock_credential = Object.new
    passkey_id = @passkey.webauthn_id
    mock_credential.define_singleton_method(:id) { passkey_id }
    mock_credential.define_singleton_method(:sign_count) { 1 }
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub(:from_get, mock_credential) do
      post verification_sign_com_in_passkeys_path(ri: "jp"),
           params: {
             challenge_id: challenge_id,
             credential: {
               id: @passkey.webauthn_id,
               response: {
                 clientDataJSON: "e30=",
                 authenticatorData: "e30=",
                 signature: "sig",
                 userHandle: "h",
               },
             },
           },
           headers: @origin_headers
    end

    assert_response :ok
    assert_equal "ok", response.parsed_body["status"]
    assert_equal sign_com_configuration_path(ri: "jp"), response.parsed_body["redirect_url"]
  end

  test "verification returns bad request when challenge is missing" do
    post verification_sign_com_in_passkeys_path(ri: "jp"),
         params: { challenge_id: "missing" },
         headers: @origin_headers

    assert_response :bad_request
    assert_includes response.body, I18n.t("errors.webauthn.challenge_invalid")
  end
end
