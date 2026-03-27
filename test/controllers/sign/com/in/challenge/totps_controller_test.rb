# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::In::Challenge::TotpsControllerTest < ActionDispatch::IntegrationTest
  fixtures :user_statuses, :user_secret_kinds, :user_secret_statuses, :user_email_statuses,
           :user_one_time_password_statuses, :user_telephone_statuses

  setup do
    host! ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    @user = create_verified_user_with_email(email_address: "com_mfa_totp_#{SecureRandom.hex(4)}@example.com")
    @user.update!(multi_factor_enabled: true)
    @user.user_telephones.create!(
      number: "+819022222222",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @totp = @user.user_one_time_passwords.create!(
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "totp",
    )

    _secret, @raw_secret = UserSecret.issue!(
      name: "TOTP MFA secret",
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

  test "new redirects when pending_mfa is missing" do
    get new_sign_com_in_challenge_totp_path(ri: "jp")

    assert_response :see_other
    assert_redirected_to new_sign_com_in_path(ri: "jp")
  end

  test "create with valid TOTP code redirects to configuration" do
    establish_pending_mfa!
    totp_code = ROTP::TOTP.new(@totp.private_key).now

    post sign_com_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: totp_code },
    }

    assert_response :found
    assert_redirected_to sign_com_configuration_path(ri: "jp")
    assert_nil session[:pending_mfa]
  end

  test "create with invalid TOTP code renders form with error" do
    establish_pending_mfa!

    post sign_com_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: "000000" },
    }

    assert_response :unprocessable_content
    assert_predicate session[:pending_mfa], :present?
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
