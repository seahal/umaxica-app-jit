require "test_helper"

class Sign::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  test "should get new" do
    get new_sign_app_registration_email_url, headers: default_headers

    assert_response :success
  end

  test "renders email registration form structure" do
    get new_sign_app_registration_email_url, headers: default_headers

    assert_response :success

    assert_select "h1", I18n.t("sign.app.registration.email.new.page_title")
  end

  test "includes navigation links to other registration flows" do
    get new_sign_app_registration_email_url, headers: default_headers

    assert_response :success

    assert_select "a[href=?]", new_sign_app_registration_path, count: 0
    assert_select "a[href=?]", new_sign_app_authentication_email_path, count: 0
  end

  test "edit returns bad_request when not logged in and no session" do
    get edit_sign_app_registration_email_url(id: "test-id"), headers: default_headers

    assert_response :bad_request
  end

  test "i18n flash messages for email registration flow exist" do
    # Check that all required i18n keys for email registration exist
    session_expired_key = "sign.app.registration.email.edit.session_expired"
    create_key = "sign.app.registration.email.create.verification_code_sent"
    update_key = "sign.app.registration.email.update.success"

    assert_not_nil I18n.t(session_expired_key, default: nil)
    assert_not_nil I18n.t(create_key, default: nil)
    assert_not_nil I18n.t(update_key, default: nil)
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "cannot register same email twice (uniqueness constraint)" do
    email = "test@example.com"

    # First registration attempt
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    assert_response :redirect

    # Verify first record created
    first_email = UserIdentityEmail.find_by(address: email)

    assert_not_nil first_email
    assert_equal "UNVERIFIED_WITH_SIGN_UP", first_email.user_identity_email_status_id

    # Second registration attempt immediately after
    # This should fail due to address uniqueness constraint
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    # Should get unprocessable content because email already exists (uniqueness validation)
    # This is the secure behavior - we don't delete other users' records
    assert_response :unprocessable_content
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "rejects wrong OTP codes with error message" do
    email = "test_wrong_otp@example.com"

    # Create registration record
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    user_email = UserIdentityEmail.find_by(address: email)

    # Attempt wrong code
    patch sign_app_registration_email_url(user_email.id),
      params: {
        id: user_email.id,
        user_identity_email: {
          pass_code: "000000"
        }
      },
      headers: default_headers

    assert_response :unprocessable_content
    assert_includes @response.body, "正しくありません"
  end

  test "deletes email record after max OTP attempts" do
    email = "test_max_attempts@example.com"

    # Create registration record
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    user_email = UserIdentityEmail.find_by(address: email)

    # Make 3 failed attempts
    3.times do
      patch sign_app_registration_email_url(user_email.id),
        params: {
          id: user_email.id,
          user_identity_email: {
            pass_code: "000000"
          }
        },
        headers: default_headers
    end

    # Verify redirect and record deletion
    assert_redirected_to new_sign_app_registration_email_path(ct: "sy", lx: "ja", ri: "jp", tz: "jst")
    assert_nil UserIdentityEmail.find_by(id: user_email.id)
  end

  test "telephone i18n flash messages exist" do
    # Check that all required i18n keys for telephone registration exist
    session_expired_key = "sign.app.registration.telephone.edit.session_expired"
    create_key = "sign.app.registration.telephone.create.verification_code_sent"
    update_key = "sign.app.registration.telephone.update.success"

    assert_not_nil I18n.t(session_expired_key, default: nil)
    assert_not_nil I18n.t(create_key, default: nil)
    assert_not_nil I18n.t(update_key, default: nil)
  end

  # Turnstile Widget Verification Tests
  test "new registration email page renders Turnstile widget" do
    get new_sign_app_registration_email_url, headers: default_headers

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  # Transaction Tests for User Creation
  # rubocop:disable Minitest/MultipleAssertions
  test "successful OTP verification creates user, audit log, and saves email in transaction" do
    email = "transaction_success@example.com"

    # Create registration record
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    user_email = UserIdentityEmail.find_by(address: email)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    initial_user_count = User.count
    initial_audit_count = UserIdentityAudit.count

    # Submit correct OTP
    patch sign_app_registration_email_url(user_email.id),
      params: {
        id: user_email.id,
        user_identity_email: {
          pass_code: correct_code
        }
      },
      headers: default_headers

    # Verify success response
    assert_redirected_to "/"

    # Verify User was created
    assert_equal initial_user_count + 1, User.count

    # Verify UserIdentityEmail was updated and linked to user
    user_email.reload

    assert_not_nil user_email.user_id
    assert_equal "VERIFIED_WITH_SIGN_UP", user_email.user_identity_email_status_id

    # Verify User has correct status
    user = user_email.user

    assert_equal "VERIFIED_WITH_SIGN_UP", user.user_identity_status_id

    # Verify UserIdentityAudit was created
    assert_equal initial_audit_count + 1, UserIdentityAudit.count
    audit = UserIdentityAudit.last

    assert_equal user.id, audit.user_id
    assert_equal user.id, audit.actor_id
    assert_equal "User", audit.actor_type
    assert_equal "SIGNED_UP_WITH_EMAIL", audit.event_id
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  test "clears session data after successful registration" do
    email = "session_clear@example.com"

    # Create registration record
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    user_email = UserIdentityEmail.find_by(address: email)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Verify session was set during registration
    assert_not_nil session[:user_email_registration]

    # Submit correct OTP
    patch sign_app_registration_email_url(user_email.id),
      params: {
        id: user_email.id,
        user_identity_email: {
          pass_code: correct_code
        }
      },
      headers: default_headers

    # Verify registration session was cleared
    assert_nil session[:user_email_registration]

    # Verify user session was set
    assert_not_nil session[:user]
    assert_equal user_email.reload.user_id, session[:user][:id]
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "OTP data is cleared after successful verification" do
    email = "otp_clear@example.com"

    # Create registration record
    post sign_app_registration_emails_url,
      params: {
        user_identity_email: {
          address: email,
          confirm_policy: "1"
        },
        "cf-turnstile-response": "test"
      },
      headers: default_headers

    user_email = UserIdentityEmail.find_by(address: email)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Verify OTP data exists before verification
    assert_not_nil user_email.get_otp

    # Submit correct OTP
    patch sign_app_registration_email_url(user_email.id),
      params: {
        id: user_email.id,
        user_identity_email: {
          pass_code: correct_code
        }
      },
      headers: default_headers

    # Verify OTP data was cleared
    user_email.reload

    assert_nil user_email.get_otp
  end

  private

  def default_headers
    { "Host" => host }
  end

  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end
end
