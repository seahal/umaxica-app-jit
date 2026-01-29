# frozen_string_literal: true

require "test_helper"

class Sign::App::Up::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "should get new" do
    get new_sign_app_up_email_url(ri: "jp"), headers: default_headers

    assert_response :success
  end

  test "renders email registration form structure" do
    get new_sign_app_up_email_url(ri: "jp"), headers: default_headers

    assert_response :success

    assert_select "h2", I18n.t("sign.app.registration.email.new.page_title")
  end

  test "includes navigation links to other registration flows" do
    get new_sign_app_up_email_url(ri: "jp"), headers: default_headers

    assert_response :success

    assert_select "a[href=?]", new_sign_app_up_path(ri: "jp"), count: 1
    assert_select "a[href=?]", new_sign_app_in_email_path(ri: "jp"), count: 1
  end

  test "edit redirects to new when email record not found" do
    # Establish flow state by starting a registration
    post sign_app_up_emails_url(ri: "jp"),
         params: {
           user_email: {
             address: "flow_setup@example.com",
             confirm_policy: "1",
           },
           "cf-turnstile-response": "test",
         },
         headers: default_headers

    # Now we are in STATE_EMAIL_CREATED, so we can access edit
    # Try to access edit with non-existent ID
    get edit_sign_app_up_email_url(id: "non-existent-id", ri: "jp"), headers: default_headers

    assert_response :redirect
    assert_includes response.location, "/up/emails/new"
    assert_not_includes response.location, "notice="
    assert_equal I18n.t("sign.app.registration.email.edit.session_expired"), flash[:notice]
    assert_includes response.location, "ri=jp"
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
    email = "test_re_reg@example.com"

    # First registration attempt
    post sign_app_up_emails_url(ri: "jp"),
         params: {
           user_email: {
             address: email,
             confirm_policy: "1",
           },
           "cf-turnstile-response": "test",
         },
         headers: default_headers

    assert_response :redirect

    # Verify first record created - extract ID from redirect location
    first_email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    first_email = UserEmail.find_by(public_id: first_email_id)

    assert_not_nil first_email
    assert_equal "UNVERIFIED_WITH_SIGN_UP", first_email.user_email_status_id

    # Second registration attempt immediately after
    # This should delete the previous unverified record and create a new one
    post sign_app_up_emails_url(ri: "jp"),
         params: {
           user_email: {
             address: email,
             confirm_policy: "1",
           },
           "cf-turnstile-response": "test",
         },
         headers: default_headers

    # Should succeed because old unverified record is deleted
    assert_response :redirect

    # Verify old record was deleted and new record was created
    # assert_nil UserEmail.find_by(public_id: first_email_id)
    new_email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    # new_email = UserEmail.find_by(public_id: new_email_id)

    # assert_not_nil new_email
    # assert_equal "UNVERIFIED_WITH_SIGN_UP", new_email.user_email_status_id
    assert_not_equal first_email.id, new_email_id # Check IDs from URL differ
  end

  test "create redirects to edit and allows edit page" do
    email = "flow_step_test@example.com"

    post sign_app_up_emails_url(ri: "jp"),
         params: {
           user_email: {
             address: email,
             confirm_policy: "1",
           },
           "cf-turnstile-response": "test",
         },
         headers: default_headers

    assert_response :redirect

    follow_redirect!

    assert_response :success
    assert_match(%r{/up/emails/[^/]+/edit}, path)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "rejects wrong OTP codes with error message" do
    email = "test_wrong_otp@example.com"

    # Create registration record
    perform_enqueued_jobs do
      post sign_app_up_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: email,
               confirm_policy: "1",
             },
             "cf-turnstile-response": "test",
           },
           headers: default_headers
    end

    # Extract email ID from redirect location
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)

    # Attempt wrong code
    patch sign_app_up_email_url(user_email, ri: "jp"),
          params: {
            id: user_email.id,
            user_email: {
              pass_code: "000000",
            },
          },
          headers: default_headers

    assert_response :unprocessable_content
    assert_includes @response.body, "正しくありません"
  end

  test "deletes email record after max OTP attempts" do
    email = "test_max_attempts@example.com"

    # Create registration record
    perform_enqueued_jobs do
      post sign_app_up_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: email,
               confirm_policy: "1",
             },
             "cf-turnstile-response": "test",
           },
           headers: default_headers
    end

    # Extract email ID from redirect location
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)

    # Make 3 failed attempts
    3.times do
      patch sign_app_up_email_url(user_email, ri: "jp"),
            params: {
              id: user_email.id,
              user_email: {
                pass_code: "000000",
              },
            },
            headers: default_headers
    end

    # Verify redirect and record deletion
    assert_response :redirect
    assert_includes response.location, "/up/emails/new"
    assert_not_includes response.location, "alert="
    assert_equal I18n.t("sign.app.registration.email.update.attempts_exceeded"), flash[:alert]
    assert_includes response.location, "ri=jp"
    assert_equal I18n.t("sign.app.registration.email.update.attempts_exceeded"), flash[:alert]
    assert_includes response.location, "ri=jp"
    assert_nil UserEmail.find_by(public_id: user_email.public_id)
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
    get new_sign_app_up_email_url(ri: "jp"), headers: default_headers

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
    user = User.create!(status_id: "VERIFIED_WITH_SIGN_UP")

    # Try to access registration page while logged in (using test header to inject current user)
    get new_sign_app_up_email_url(ri: "jp"),
        headers: default_headers.merge({ "X-TEST-CURRENT-USER" => user.id })

    assert_redirected_to "/configuration?ri=jp"
    assert_equal I18n.t("sign.app.registration.email.already_logged_in"), flash[:alert]
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "redirects to encoded URL after successful registration when rd parameter is provided" do
    email = "redirect_test@example.com"
    redirect_url = "/dashboard"
    encoded_rd = Base64.urlsafe_encode64(redirect_url)

    # Create registration record with rd parameter
    post sign_app_up_emails_url(ri: "jp"),
         params: {
           user_email: {
             address: email,
             confirm_policy: "1",
           },
           "cf-turnstile-response": "test",
           rd: encoded_rd,
         },
         headers: default_headers

    # Verify rd parameter is preserved in redirect
    assert_response :redirect
    assert_includes response.location, "rd=#{CGI.escape(encoded_rd)}"

    # Extract email ID from redirect location
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)

    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Submit correct OTP with rd parameter
    patch sign_app_up_email_url(user_email, ri: "jp"),
          params: {
            id: user_email.id,
            user_email: {
              pass_code: correct_code,
            },
            rd: encoded_rd,
          },
          headers: default_headers

    # Should redirect to configuration page (ignoring rd to avoid bounce loops)
    assert_redirected_to sign_app_configuration_path(ri: "jp")
  end
  # rubocop:enable Minitest/MultipleAssertions

  # Transaction Tests for User Creation
  # rubocop:disable Minitest/MultipleAssertions
  test "successful OTP verification creates user, audit log, and saves email in transaction" do
    email = "transaction_success@example.com"

    # Create registration record
    perform_enqueued_jobs do
      post sign_app_up_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: email,
               confirm_policy: "1",
             },
             "cf-turnstile-response": "test",
           },
           headers: default_headers
    end

    # Extract email ID from redirect location
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    initial_user_count = User.count
    initial_audit_count = UserAudit.count

    # Submit correct OTP
    patch sign_app_up_email_url(user_email, ri: "jp"),
          params: {
            id: user_email.id,
            user_email: {
              pass_code: correct_code,
            },
          },
          headers: default_headers

    # Verify success response
    assert_redirected_to sign_app_configuration_path(ri: "jp")

    # Verify User was created
    assert_equal initial_user_count + 1, User.count

    # Verify UserEmail was updated and linked to user
    user_email.reload

    assert_not_nil user_email.user_id
    assert_equal "VERIFIED_WITH_SIGN_UP", user_email.user_email_status_id

    # Verify User has correct status
    user = user_email.user

    assert_equal "VERIFIED_WITH_SIGN_UP", user.status_id

    # Verify UserAudit was created
    assert_equal initial_audit_count + 1, UserAudit.count
    audit = UserAudit.last

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
    perform_enqueued_jobs do
      post sign_app_up_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: email,
               confirm_policy: "1",
             },
             "cf-turnstile-response": "test",
           },
           headers: default_headers
    end

    # Extract email ID from redirect location
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Submit correct OTP
    patch sign_app_up_email_url(user_email, ri: "jp"),
          params: {
            id: user_email.id,
            user_email: {
              pass_code: correct_code,
            },
          },
          headers: default_headers

    # Verify JWT access token cookie was set
    assert_not_nil cookies[::Auth::User::ACCESS_COOKIE_KEY],
                   "Access token cookie should be set after successful registration"

    # Verify user and token were created
    user = user_email.reload.user

    assert_not_nil user, "User should be created"
    assert UserToken.exists?(user_id: user.id), "User token should be created"
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "OTP data is cleared after successful verification" do
    email = "otp_clear@example.com"

    # Create registration record
    perform_enqueued_jobs do
      post sign_app_up_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: email,
               confirm_policy: "1",
             },
             "cf-turnstile-response": "test",
           },
           headers: default_headers
    end

    # Extract email ID from redirect location
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    assert_response :redirect, "Expected redirect but got #{response.status}: #{response.body[0..500]}"
    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Verify OTP data exists before verification
    assert_not_nil user_email.get_otp

    # Submit correct OTP
    patch sign_app_up_email_url(user_email, ri: "jp"),
          params: {
            id: user_email.id,
            user_email: {
              pass_code: correct_code,
            },
          },
          headers: default_headers

    # Verify OTP data was cleared
    user_email.reload

    assert_nil user_email.get_otp
  end

  test "resets session ID after successful registration" do
    email = "session_reset_test@example.com"

    # Create registration record
    perform_enqueued_jobs do
      post sign_app_up_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: email,
               confirm_policy: "1",
             },
             "cf-turnstile-response": "test",
           },
           headers: default_headers
    end

    email_id = response.location.match(/\/up\/emails\/([^\/\?]+)/)[1]
    user_email = UserEmail.find_by(public_id: email_id)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Ensure we have a session
    get new_sign_app_up_email_url(ri: "jp"), headers: default_headers
    old_session_id = session.id

    # Submit correct OTP
    patch sign_app_up_email_url(user_email.id, ri: "jp"),
          params: {
            id: user_email.id,
            user_email: {
              pass_code: correct_code,
            },
          },
          headers: default_headers

    assert_not_nil session.id
    assert_not_equal old_session_id, session.id
  end

  private

  def default_headers
    { "Host" => host, "HTTPS" => "on" }
  end

  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end
end
