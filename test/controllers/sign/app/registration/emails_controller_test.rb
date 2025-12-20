require "test_helper"

class Sign::App::Registration::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    CloudflareTurnstile.test_mode = true
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

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

  test "edit redirects to new when email record not found" do
    get edit_sign_app_registration_email_url(id: "non-existent-id"), headers: default_headers

    assert_response :redirect
    assert_includes response.location, new_sign_app_registration_email_path
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
  test "can re-register same email if previous registration was unverified" do
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

    # Verify first record created - extract ID from redirect location
    first_email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    first_email = UserIdentityEmail.find(first_email_id)

    assert_not_nil first_email
    assert_equal "UNVERIFIED_WITH_SIGN_UP", first_email.user_identity_email_status_id

    # Second registration attempt immediately after
    # This should delete the previous unverified record and create a new one
    post sign_app_registration_emails_url,
         params: {
           user_identity_email: {
             address: email,
             confirm_policy: "1"
           },
           "cf-turnstile-response": "test"
         },
         headers: default_headers

    # Should succeed because old unverified record is deleted
    assert_response :redirect

    # Verify old record was deleted and new record was created
    assert_nil UserIdentityEmail.find_by(id: first_email_id)
    new_email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    new_email = UserIdentityEmail.find(new_email_id)

    assert_not_nil new_email
    assert_equal "UNVERIFIED_WITH_SIGN_UP", new_email.user_identity_email_status_id
    assert_not_equal first_email_id, new_email.id
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

    # Extract email ID from redirect location
    email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    user_email = UserIdentityEmail.find(email_id)

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

    # Extract email ID from redirect location
    email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    user_email = UserIdentityEmail.find(email_id)

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
    assert_response :redirect
    assert_includes response.location, new_sign_app_registration_email_path
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

  test "turnstile validation error message i18n key exists" do
    # Verify the turnstile error message key exists in all locales
    assert_not_nil I18n.t("sign.app.registration.email.create.turnstile_validation_failed", locale: :ja, default: nil)
    assert_not_nil I18n.t("sign.app.registration.email.create.turnstile_validation_failed", locale: :en, default: nil)
  end

  test "redirects to root when user is already logged in" do
    # Create a user and log them in
    user = User.create!(user_identity_status_id: "VERIFIED_WITH_SIGN_UP")

    # Try to access registration page while logged in (using test header to inject current user)
    get new_sign_app_registration_email_url,
        headers: default_headers.merge({ "X-TEST-CURRENT-USER" => user.id })

    assert_redirected_to "/"
    assert_equal I18n.t("sign.app.registration.email.already_logged_in"), flash[:alert]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "redirects to encoded URL after successful registration when rd parameter is provided" do
    email = "redirect_test@example.com"
    redirect_url = "https://#{ENV['APEX_SERVICE_URL']}/dashboard"
    encoded_rd = Base64.urlsafe_encode64(redirect_url)

    # Create registration record with rd parameter
    post sign_app_registration_emails_url,
         params: {
           user_identity_email: {
             address: email,
             confirm_policy: "1"
           },
           "cf-turnstile-response": "test",
           rd: encoded_rd
         },
         headers: default_headers

    # Verify rd parameter is preserved in redirect
    assert_response :redirect
    assert_includes response.location, "rd=#{CGI.escape(encoded_rd)}"

    # Extract email ID from redirect location
    email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    user_email = UserIdentityEmail.find(email_id)

    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Submit correct OTP with rd parameter
    patch sign_app_registration_email_url(user_email.id),
          params: {
            id: user_email.id,
            user_identity_email: {
              pass_code: correct_code
            },
            rd: encoded_rd
          },
          headers: default_headers

    # Should redirect to the encoded URL
    assert_redirected_to redirect_url
  end
  # rubocop:enable Minitest/MultipleAssertions

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

    # Extract email ID from redirect location
    email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    user_email = UserIdentityEmail.find(email_id)
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
  test "sets user session after successful registration" do
    email = "session_set@example.com"

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

    # Extract email ID from redirect location
    email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    user_email = UserIdentityEmail.find(email_id)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Submit correct OTP
    patch sign_app_registration_email_url(user_email.id),
          params: {
            id: user_email.id,
            user_identity_email: {
              pass_code: correct_code
            }
          },
          headers: default_headers

    # Verify JWT access token cookie was set
    assert_not_nil cookies[:access_user_token], "Access token cookie should be set after successful registration"

    # Verify user and token were created
    user = user_email.reload.user

    assert_not_nil user, "User should be created"
    assert UserToken.exists?(user_id: user.id), "User token should be created"
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

    # Extract email ID from redirect location
    email_id = response.location.match(/\/registration\/emails\/([^\/\?]+)/)[1]
    user_email = UserIdentityEmail.find(email_id)
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
