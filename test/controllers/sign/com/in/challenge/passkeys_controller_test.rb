# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"
require "ostruct"

class Sign::Com::In::Challenge::PasskeysControllerTest < ActionDispatch::IntegrationTest
  fixtures :user_statuses, :user_passkey_statuses, :user_secret_kinds, :user_secret_statuses, :user_email_statuses,
           :user_one_time_password_statuses, :user_telephone_statuses

  setup do
    @host = ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    host! @host
    @origin_headers = { "HTTP_ORIGIN" => "http://#{@host}", "Origin" => "http://#{@host}" }.freeze
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    @original_trusted_origins = Webauthn.method(:trusted_origins)
    Webauthn.define_singleton_method(:trusted_origins) { ["http://#{@host}", "http://sign.app.localhost"] }

    @user = create_verified_user_with_email(email_address: "com_mfa_passkey_#{SecureRandom.hex(4)}@example.com")
    @user.update!(multi_factor_enabled: true)
    @user.user_telephones.create!(
      number: "+819033333333",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )

    @passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: Base64.urlsafe_encode64("com_mfa_passkey_id", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "mfa-passkey-public",
      sign_count: 5,
      description: "MFA Passkey",
      status_id: UserPasskeyStatus::ACTIVE,
    )

    _secret, @raw_secret = UserSecret.issue!(
      name: "Passkey MFA secret",
      user_id: @user.id,
      user_secret_kind_id: UserSecretKind::PERMANENT,
      uses: 10,
      status: :active,
    )
  end

  teardown do
    Webauthn.define_singleton_method(:trusted_origins, @original_trusted_origins) if @original_trusted_origins
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "new requires pending MFA session" do
    get new_sign_com_in_challenge_passkey_path(ri: "jp"), headers: @origin_headers

    assert_redirected_to new_sign_com_in_path(ri: "jp")
  end

  test "create verifies passkey and redirects on success" do
    establish_pending_mfa!

    Sign::Com::In::Challenge::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      get new_sign_com_in_challenge_passkey_path(ri: "jp"), headers: @origin_headers
    end

    assert_response :success
    challenge_id = session[:passkey_challenges].keys.first

    mock_credential = OpenStruct.new(id: @passkey.webauthn_id, sign_count: 6)
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub(:from_get, mock_credential) do
      post sign_com_in_challenge_passkey_path(ri: "jp"),
           params: {
             mfa_passkey_form: {
               challenge_id: challenge_id,
               credential_json: {
                 id: @passkey.webauthn_id,
                 type: "public-key",
                 response: {
                   clientDataJSON: "dummy",
                   authenticatorData: "dummy",
                   signature: "dummy",
                   userHandle: @user.public_id,
                 },
               }.to_json,
             },
           },
           headers: @origin_headers
    end

    assert_response :redirect
    assert_redirected_to sign_com_configuration_path(ri: "jp")
    assert_nil session[:pending_mfa]
    assert_equal 6, @passkey.reload.sign_count
  end

  test "new redirects to challenge when no passkeys are available" do
    establish_pending_mfa!
    @user.user_passkeys.update_all(status_id: UserPasskeyStatus::REVOKED)

    Sign::Com::In::Challenge::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      get new_sign_com_in_challenge_passkey_path(ri: "jp"), headers: @origin_headers
    end

    assert_redirected_to sign_com_in_challenge_path(ri: "jp")
    assert_equal I18n.t("errors.webauthn.no_passkeys_available"), flash[:alert]
  end

  test "create redirects when passkey credential mismatches pending user" do
    establish_pending_mfa!

    Sign::Com::In::Challenge::PasskeysController.any_instance.stub(:validate_webauthn_origin!, true) do
      get new_sign_com_in_challenge_passkey_path(ri: "jp"), headers: @origin_headers
    end
    challenge_id = session[:passkey_challenges].keys.first

    other_user = create_verified_user_with_email(email_address: "other_passkey_user@example.com")
    other_user.user_telephones.create!(
      number: "+819033344444",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    other_passkey = UserPasskey.create!(
      user: other_user,
      webauthn_id: Base64.urlsafe_encode64("other_com_mfa_passkey_id", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "other-public-key",
      sign_count: 1,
      description: "Other Passkey",
      status_id: UserPasskeyStatus::ACTIVE,
    )

    mock_credential = OpenStruct.new(id: other_passkey.webauthn_id, sign_count: 2)
    mock_credential.define_singleton_method(:verify) { |*_args| true }

    WebAuthn::Credential.stub(:from_get, mock_credential) do
      post sign_com_in_challenge_passkey_path(ri: "jp"),
           params: {
             mfa_passkey_form: {
               challenge_id: challenge_id,
               credential_json: {
                 id: other_passkey.webauthn_id,
                 type: "public-key",
                 response: {},
               }.to_json,
             },
           },
           headers: @origin_headers
    end

    assert_redirected_to sign_com_in_challenge_path(ri: "jp")
    assert_equal I18n.t("errors.webauthn.credential_not_found"), flash[:alert]
  end

  private

  def establish_pending_mfa!
    post(
      sign_com_in_secret_path(ri: "jp"), params: {
        secret_login_form: {
          identifier: @user.user_emails.first.address,
          secret_value: @raw_secret,
        },
        "cf-turnstile-response": "test_token",
      },
    )

    assert_response :redirect
  end
end
