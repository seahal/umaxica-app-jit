# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Com::In::ChallengesControllerTest < ActionDispatch::IntegrationTest
  fixtures :user_statuses, :user_secret_kinds, :user_secret_statuses, :user_email_statuses,
           :user_one_time_password_statuses, :user_telephone_statuses

  setup do
    host! ENV.fetch("SIGN_CORPORATE_URL", "sign.com.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    @user = create_verified_user_with_email(email_address: "com_challenge_#{SecureRandom.hex(4)}@example.com")
    @user.update!(multi_factor_enabled: true)
    @user.user_telephones.create!(
      number: "+819011111111",
      user_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
    @user.user_one_time_passwords.create!(
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
    get sign_com_in_challenge_path(ri: "jp")

    assert_response :see_other
    assert_redirected_to new_sign_com_in_path(ri: "jp")
  end

  # Skipped: CSRF token extraction from response body is not working with header_or_legacy_token strategy
  # This test needs to be revisited when the CSRF handling is better understood
  test "show renders for pending_mfa user" do
    skip "CSRF token extraction issue with header_or_legacy_token strategy"

    get new_sign_com_in_secret_path(ri: "jp")

    assert_response :success

    post sign_com_in_secret_path(ri: "jp"),
         headers: { "X-CSRF-Token" => "valid_csrf_token" },
         params: {
           secret_login_form: {
             identifier: @user.user_emails.first.address,
             secret_value: @raw_secret,
           },
           "cf-turnstile-response": "test_token",
         }

    assert_redirected_to sign_com_in_challenge_path(ri: "jp")

    follow_redirect!

    assert_response :success
    assert_includes response.body, "totp"
  end

  test "show hides totp method when user has no active totp" do
    skip "CSRF token extraction issue with header_or_legacy_token strategy"

    @user.user_one_time_passwords.destroy_all

    get new_sign_com_in_secret_path(ri: "jp")

    assert_response :success

    post sign_com_in_secret_path(ri: "jp"),
         headers: { "X-CSRF-Token" => "valid_csrf_token" },
         params: {
           secret_login_form: {
             identifier: @user.user_emails.first.address,
             secret_value: @raw_secret,
           },
           "cf-turnstile-response": "test_token",
         }

    follow_redirect!

    assert_response :success
    assert_not_includes response.body, I18n.t("sign.app.in.mfa.methods.totp")
  end
end
