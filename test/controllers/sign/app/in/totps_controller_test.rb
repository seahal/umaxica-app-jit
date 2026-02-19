# frozen_string_literal: true

require "test_helper"

class Sign::App::In::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_one_time_passwords, :user_one_time_password_statuses,
           :user_secrets, :user_secret_statuses, :user_email_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @user.update!(multi_factor_enabled: true, status_id: UserStatus::ACTIVE)

    # Ensure user has a verified email and a secret for login
    @user.user_emails.destroy_all
    @email = @user.user_emails.create!(address: "test-mfa@example.com", user_email_status_id: UserEmailStatus::VERIFIED)

    @user.user_secrets.destroy_all
    _secret, @raw_secret = UserSecret.issue!(
      name: "Login Secret",
      user_id: @user.id,
      user_secret_kind_id: UserSecretKind::PERMANENT,
      uses: 10,
      status: :active,
    )

    # Clear existing TOTPs to avoid limit error
    @user.user_one_time_passwords.destroy_all

    @totp = UserOneTimePassword.create!(
      user: @user,
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "Test TOTP",
    )

    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  def trigger_mfa_login
    post sign_app_in_secret_url(ri: "jp"), params: {
      secret_login_form: {
        identifier: @email.address,
        secret_value: @raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }
    assert_redirected_to sign_app_in_challenge_path(ri: "jp")
  end

  test "new redirects to sign in when mfa_user_id is missing" do
    get new_sign_app_in_challenge_totp_path(ri: "jp")

    assert_redirected_to new_sign_app_in_path(ri: "jp")
  end

  test "new with mfa_user_id renders form" do
    trigger_mfa_login

    get new_sign_app_in_challenge_totp_path(ri: "jp")

    assert_response :success
    assert_select "form"
  end

  test "create with valid TOTP code logs user in" do
    trigger_mfa_login
    totp_code = ROTP::TOTP.new(@totp.private_key).now

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: totp_code },
    }

    assert_redirected_to sign_app_in_checkpoint_path(ri: "jp")
  end

  test "create with invalid TOTP code renders form with error" do
    trigger_mfa_login

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: "000000" },
    }

    assert_response :unprocessable_content
    assert_select "form"
  end

  test "create without mfa_user_id redirects to sign in" do
    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: "123456" },
    }

    assert_redirected_to new_sign_app_in_path(ri: "jp")
  end

  test "create with invalid token format renders form with error" do
    trigger_mfa_login

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: "123" },
    }

    assert_response :unprocessable_content
    assert_select "form"
  end

  test "create with blank token renders form with error" do
    trigger_mfa_login

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: "" },
    }

    assert_response :unprocessable_content
    assert_select "form"
  end

  test "successful TOTP updates last_otp_at timestamp" do
    trigger_mfa_login
    totp_code = ROTP::TOTP.new(@totp.private_key).now

    initial_last_otp_at = @totp.reload.last_otp_at

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: totp_code },
    }

    assert_not_equal initial_last_otp_at, @totp.reload.last_otp_at
  end

  test "create with multiple active TOTPs tries all" do
    trigger_mfa_login

    # Clear and create 2 TOTPs (limit is 2)
    @user.user_one_time_passwords.destroy_all
    UserOneTimePassword.create!(
      user: @user,
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "TOTP 1",
    )
    t2 = UserOneTimePassword.create!(
      user: @user,
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "TOTP 2",
    )

    totp_code = ROTP::TOTP.new(t2.private_key).now

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: totp_code },
    }

    assert_redirected_to sign_app_in_checkpoint_path(ri: "jp")
  end
end
