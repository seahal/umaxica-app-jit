# frozen_string_literal: true

require "test_helper"

class Sign::App::In::MfasControllerTest < ActionDispatch::IntegrationTest
  fixtures :user_statuses, :user_passkey_statuses, :user_secret_kinds, :user_secret_statuses, :user_email_statuses,
           :user_one_time_password_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
    @user = User.create!
    @email = "mfa_hub_#{SecureRandom.hex(4)}@example.com".freeze
    @user.user_emails.create!(address: @email, user_email_status_id: UserEmailStatus::VERIFIED)
    UserOneTimePassword.create!(
      user: @user,
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "totp",
    )
    _secret, @raw_secret = UserSecret.issue!(
      name: "Hub secret",
      user_id: @user.id,
      user_secret_kind_id: UserSecretKind::PERMANENT,
      uses: 10,
      status: :active,
    )
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "show requires pending_mfa" do
    get sign_app_in_mfa_path(ri: "jp")

    assert_redirected_to new_sign_app_in_path(ri: "jp")
  end

  test "show renders for pending_mfa user" do
    post sign_app_in_secret_path(ri: "jp"), params: {
      secret_login_form: {
        identifier: @email,
        secret_value: @raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }
    assert_redirected_to sign_app_in_mfa_path(ri: "jp")

    get sign_app_in_mfa_path(ri: "jp")
    assert_response :success
  end
end
