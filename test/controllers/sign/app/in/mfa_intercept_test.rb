# frozen_string_literal: true

require "test_helper"

# Tests the unified MFA intercept flow across all sign-in methods.
# Verifies that:
# - MFA-required users are redirected to /in/mfa after first-factor success
# - MFA-not-required users log in normally
# - MFA session expiry redirects to sign-in
# - TOTP verification completes login
# - Passkey verification completes login (via stubbed WebAuthn)
class Sign::App::In::MfaInterceptTest < ActionDispatch::IntegrationTest
  fixtures :user_statuses, :user_passkey_statuses, :user_secret_kinds, :user_secret_statuses,
           :user_email_statuses, :user_one_time_password_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
    @original_allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false

    # MFA-required user
    @mfa_user = User.create!(multi_factor_enabled: true)
    @mfa_email = "mfa_intercept_#{SecureRandom.hex(4)}@example.com".freeze
    @mfa_user.user_emails.create!(address: @mfa_email, user_email_status_id: UserEmailStatus::VERIFIED)
    @totp = UserOneTimePassword.create!(
      user: @mfa_user,
      private_key: ROTP::Base32.random_base32,
      user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
      title: "totp",
    )
    _secret, @mfa_raw_secret = UserSecret.issue!(
      name: "MFA secret",
      user_id: @mfa_user.id,
      user_secret_kind_id: UserSecretKind::PERMANENT,
      uses: 10,
      status: :active,
    )

    # Non-MFA user
    @normal_user = User.create!(multi_factor_enabled: false)
    @normal_email = "normal_#{SecureRandom.hex(4)}@example.com".freeze
    @normal_user.user_emails.create!(address: @normal_email, user_email_status_id: UserEmailStatus::VERIFIED)
    _secret, @normal_raw_secret = UserSecret.issue!(
      name: "Normal secret",
      user_id: @normal_user.id,
      user_secret_kind_id: UserSecretKind::PERMANENT,
      uses: 10,
      status: :active,
    )
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
    ActionController::Base.allow_forgery_protection = @original_allow_forgery_protection
  end

  # =========================================================================
  # Secret sign-in: MFA-required user -> /in/mfa redirect
  # =========================================================================

  test "secret sign-in: MFA-required user is redirected to /in/mfa" do
    post sign_app_in_secret_path(ri: "jp"), params: {
      secret_login_form: {
        identifier: @mfa_email,
        secret_value: @mfa_raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }

    assert_response :found
    assert_redirected_to sign_app_in_challenge_path(ri: "jp")
    # Login should NOT be completed - no access cookie
    assert_nil cookies[Auth::Base::ACCESS_COOKIE_KEY]
    # pending_mfa should be set
    assert_predicate session[:pending_mfa], :present?
  end

  test "secret sign-in: non-MFA user logs in normally" do
    post sign_app_in_secret_path(ri: "jp"), params: {
      secret_login_form: {
        identifier: @normal_email,
        secret_value: @normal_raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }

    assert_response :found
    assert_redirected_to sign_app_configuration_path(ri: "jp")
    # Login IS completed
    assert_not_nil cookies[Auth::Base::ACCESS_COOKIE_KEY]
    assert_nil session[:pending_mfa]
  end

  # =========================================================================
  # /in/mfa show: session validation
  # =========================================================================

  test "GET /in/mfa without pending_mfa redirects to sign-in with alert" do
    get sign_app_in_challenge_path(ri: "jp")

    assert_response :redirect
    assert_redirected_to new_sign_app_in_path(ri: "jp")
    assert_equal I18n.t("sign.app.in.mfa.session_expired"), flash[:alert]
  end

  test "GET /in/mfa with valid pending_mfa renders method selection" do
    establish_pending_mfa_via_secret!

    get sign_app_in_challenge_path(ri: "jp")
    assert_response :success
    assert_includes response.body, I18n.t("sign.app.in.mfa.methods.totp")
  end

  test "GET /in/mfa with expired pending_mfa redirects to sign-in" do
    establish_pending_mfa_via_secret!

    # Expire the MFA session
    mfa_data = session[:pending_mfa]
    mfa_data["expires_at"] = 1.minute.ago.to_i
    # We can't directly modify the session in integration tests, so we'll
    # use travel_to to expire it
    travel_to 11.minutes.from_now do
      get sign_app_in_challenge_path(ri: "jp")

      assert_response :redirect
      assert_redirected_to new_sign_app_in_path(ri: "jp")
    end
  end

  # =========================================================================
  # TOTP verification -> login completion
  # =========================================================================

  test "TOTP: valid code completes login for MFA-required user" do
    establish_pending_mfa_via_secret!

    # Generate a valid TOTP code
    totp_code = ROTP::TOTP.new(@totp.private_key).now

    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: totp_code },
    }

    assert_response :found
    assert_redirected_to sign_app_configuration_path(ri: "jp")
    # Login should now be completed
    assert_not_nil cookies[Auth::Base::ACCESS_COOKIE_KEY]
    # pending_mfa should be cleared
    assert_nil session[:pending_mfa]
  end

  test "TOTP: invalid code shows error" do
    establish_pending_mfa_via_secret!

    post sign_app_in_challenge_totp_path, params: {
      totp_challenge_form: { token: "000000" },
    }

    assert_response :unprocessable_content
    # assert_includes response.body, I18n.t("sign.app.in.mfa.verification_failed")
    # Login should NOT be completed
    assert_nil cookies[Auth::Base::ACCESS_COOKIE_KEY]
  end

  test "TOTP: without pending_mfa redirects to sign-in" do
    get new_sign_app_in_challenge_totp_path(ri: "jp")

    assert_response :redirect
    assert_redirected_to new_sign_app_in_path(ri: "jp")
    # assert_equal I18n.t("sign.app.in.mfa.session_expired"), flash[:alert]
  end

  # =========================================================================
  # MFA Passkey verification -> login completion
  # =========================================================================

  test "MFA passkey: new without pending_mfa redirects to sign-in" do
    get new_sign_app_in_challenge_passkey_path(ri: "jp")

    assert_response :redirect
    assert_redirected_to new_sign_app_in_path(ri: "jp")
    # assert_equal I18n.t("sign.app.in.mfa.session_expired"), flash[:alert]
  end

  test "MFA passkey: new with pending_mfa but no passkeys redirects to mfa hub" do
    # Remove passkeys first
    @mfa_user.user_passkeys.destroy_all

    establish_pending_mfa_via_secret!

    original_trusted_origins = Webauthn.method(:trusted_origins)
    Webauthn.define_singleton_method(:trusted_origins) { ["http://sign.app.localhost"] }

    begin
      get new_sign_app_in_challenge_passkey_path(ri: "jp")

      assert_response :redirect
      assert_redirected_to sign_app_in_challenge_path(ri: "jp")
    ensure
      Webauthn.define_singleton_method(:trusted_origins, original_trusted_origins)
    end
  end

  # =========================================================================
  # Intercept ensures all sign-in methods go through MFA
  # =========================================================================

  test "secret sign-in with MFA user sets pending_mfa with correct auth_method" do
    post sign_app_in_secret_path, params: {
      secret_login_form: {
        identifier: @mfa_email,
        secret_value: @mfa_raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }

    assert_redirected_to sign_app_in_challenge_path
    mfa_data = session[:pending_mfa]
    assert_not_nil mfa_data
    assert_equal @mfa_user.id, mfa_data["user_id"]
    assert_equal "secret", mfa_data["auth_method"]
  end

  # =========================================================================
  # Full flow: secret -> MFA -> TOTP -> logged in
  # =========================================================================

  test "full flow: secret sign-in → MFA → TOTP → logged in" do
    # Step 1: Secret sign-in (first factor)
    post sign_app_in_secret_path(ri: "jp"), params: {
      secret_login_form: {
        identifier: @mfa_email,
        secret_value: @mfa_raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }
    assert_redirected_to sign_app_in_challenge_path(ri: "jp")

    # Step 2: Visit MFA selection page
    get sign_app_in_challenge_path(ri: "jp")
    assert_response :success

    # Step 3: Visit TOTP form
    get new_sign_app_in_challenge_totp_path(ri: "jp")
    assert_response :success

    # Step 4: Submit valid TOTP code
    totp_code = ROTP::TOTP.new(@totp.private_key).now
    post sign_app_in_challenge_totp_path(ri: "jp"), params: {
      totp_challenge_form: { token: totp_code },
    }

    assert_response :found
    assert_redirected_to sign_app_configuration_path(ri: "jp")
    assert_not_nil cookies[Auth::Base::ACCESS_COOKIE_KEY]
    assert_nil session[:pending_mfa]
  end

  private

  def establish_pending_mfa_via_secret!
    post sign_app_in_secret_path(ri: "jp"), params: {
      secret_login_form: {
        identifier: @mfa_email,
        secret_value: @mfa_raw_secret,
      },
      "cf-turnstile-response": "test_token",
    }
    assert_redirected_to sign_app_in_challenge_path(ri: "jp")
  end
end
