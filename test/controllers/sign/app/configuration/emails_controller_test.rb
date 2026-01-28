# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  def request_headers
    { "Host" => @host, "X-TEST-CURRENT-USER" => @user.id }
  end

  # ==========================================================================
  # Authentication Tests
  # ==========================================================================

  test "should redirect index when not logged in" do
    get sign_app_configuration_emails_url(ri: "jp")
    assert_response :redirect
    target_path = new_sign_app_in_path
    assert_match %r{#{Regexp.escape(target_path)}\?.*ri=jp}, response.headers["Location"]
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "should redirect new when not logged in" do
    get new_sign_app_configuration_email_url(ri: "jp")
    assert_response :redirect
  end

  # ==========================================================================
  # Index Tests
  # ==========================================================================

  test "should get index" do
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "index shows user emails" do
    # Create a verified email for the user
    UserEmail.create!(
      address: "verified@example.com",
      user: @user,
      user_email_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "td", text: "verified@example.com"
  end

  test "index does not show unverified emails" do
    UserEmail.create!(
      address: "unverified@example.com",
      user: @user,
      user_email_status_id: "UNVERIFIED_WITH_SIGN_UP"
    )

    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "td", text: "unverified@example.com", count: 0
  end

  # ==========================================================================
  # New Tests
  # ==========================================================================

  test "should get new" do
    get new_sign_app_configuration_email_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "new page renders email input form" do
    get new_sign_app_configuration_email_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "input[type=email][name='user_email[address]']"
  end

  test "new page renders turnstile widget" do
    get new_sign_app_configuration_email_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  # ==========================================================================
  # Create Tests
  # ==========================================================================

  test "create initiates email verification and redirects to edit" do
    email_address = "newaddress@example.com"

    perform_enqueued_jobs do
      post sign_app_configuration_emails_url(ri: "jp"),
           params: {
             user_email: { address: email_address },
             "cf-turnstile-response": "test"
           },
           headers: request_headers
    end

    assert_response :redirect
    assert_match %r{/configuration/emails/[^/]+/edit}, response.location

    # Verify UserEmail was created
    user_email = UserEmail.find_by(address: email_address)
    assert_not_nil user_email
    assert_equal "UNVERIFIED_WITH_SIGN_UP", user_email.user_email_status_id
  end

  test "create fails with invalid email format" do
    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: "invalid-email" },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    assert_response :unprocessable_content
  end

  test "create fails with duplicate email" do
    UserEmail.create!(
      address: "existing@example.com",
      user: users(:two),
      user_email_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: "existing@example.com" },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    assert_response :unprocessable_content
  end

  test "create fails with turnstile validation failure" do
    CloudflareTurnstile.test_validation_response = { "success" => false }

    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: "test@example.com" },
           "cf-turnstile-response": "invalid"
         },
         headers: request_headers

    assert_response :unprocessable_content
  end

  # ==========================================================================
  # Edit Tests
  # ==========================================================================

  test "edit requires valid flow state" do
    # Create email but don't advance flow
    email = UserEmail.create!(
      address: "test@example.com",
      user_email_status_id: "UNVERIFIED_WITH_SIGN_UP"
    )

    get edit_sign_app_configuration_email_url(email, ri: "jp"), headers: request_headers

    # Should redirect due to flow enforcement
    assert_response :redirect
  end

  test "edit shows OTP input form when flow is correct" do
    # Initiate verification to set flow state
    email_address = "flowtest@example.com"

    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: email_address },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    # Extract email ID from redirect location and make a separate request
    user_email = UserEmail.find_by(address: email_address)
    get edit_sign_app_configuration_email_url(user_email, ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "input[name='user_email[pass_code]']"
  end

  test "edit redirects when email not found" do
    # Initiate verification to set flow state
    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: "setup@example.com" },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    # Try to access edit with non-existent ID
    get edit_sign_app_configuration_email_url(id: "nonexistent", ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_match %r{/configuration/emails/new}, response.location
  end

  test "edit redirects when OTP expired" do
    # Initiate verification
    email_address = "expired@example.com"

    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: email_address },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    user_email = UserEmail.find_by(address: email_address)

    # Expire the OTP
    user_email.update!(otp_expires_at: 1.hour.ago)

    # Try to access edit
    get edit_sign_app_configuration_email_url(user_email, ri: "jp"), headers: request_headers

    assert_response :redirect
  end

  # ==========================================================================
  # Update Tests
  # ==========================================================================

  # rubocop:disable Minitest/MultipleAssertions
  test "update with correct OTP verifies email and links to user" do
    email_address = "verify@example.com"

    # Initiate verification
    perform_enqueued_jobs do
      post sign_app_configuration_emails_url(ri: "jp"),
           params: {
             user_email: { address: email_address },
             "cf-turnstile-response": "test"
           },
           headers: request_headers
    end

    user_email = UserEmail.find_by(address: email_address)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Submit correct OTP
    patch sign_app_configuration_email_url(user_email, ri: "jp"),
          params: {
            user_email: { pass_code: correct_code }
          },
          headers: request_headers

    assert_response :redirect

    # Verify email was linked to user
    user_email.reload
    assert_equal @user.id, user_email.user_id
    assert_equal "VERIFIED_WITH_SIGN_UP", user_email.user_email_status_id
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "update with wrong OTP renders edit with error" do
    email_address = "wrongotp@example.com"

    # Initiate verification
    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: email_address },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    user_email = UserEmail.find_by(address: email_address)

    # Submit wrong OTP
    patch sign_app_configuration_email_url(user_email, ri: "jp"),
          params: {
            user_email: { pass_code: "000000" }
          },
          headers: request_headers

    assert_response :unprocessable_content
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "update deletes email after max OTP attempts" do
    email_address = "maxattempts@example.com"

    # Initiate verification
    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: email_address },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    user_email = UserEmail.find_by(address: email_address)

    # Make 3 failed attempts
    3.times do
      patch sign_app_configuration_email_url(user_email, ri: "jp"),
            params: {
              user_email: { pass_code: "000000" }
            },
            headers: request_headers
    end

    # Verify redirect and record deletion
    assert_response :redirect
    assert_nil UserEmail.find_by(address: email_address)
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "update clears OTP data after successful verification" do
    email_address = "clearotp@example.com"

    # Initiate verification
    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: email_address },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    user_email = UserEmail.find_by(address: email_address)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    # Verify OTP data exists before verification
    assert_not_nil user_email.get_otp

    # Submit correct OTP
    patch sign_app_configuration_email_url(user_email, ri: "jp"),
          params: {
            user_email: { pass_code: correct_code }
          },
          headers: request_headers

    # Verify OTP data was cleared
    user_email.reload
    assert_nil user_email.get_otp
  end

  # ==========================================================================
  # Show Tests
  # ==========================================================================

  test "show displays verified email" do
    # Create and verify an email
    email_address = "showtest@example.com"

    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: email_address },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    user_email = UserEmail.find_by(address: email_address)
    otp_data = user_email.get_otp
    hotp = ROTP::HOTP.new(otp_data[:otp_private_key])
    correct_code = hotp.at(otp_data[:otp_counter]).to_s

    patch sign_app_configuration_email_url(user_email, ri: "jp"),
          params: {
            user_email: { pass_code: correct_code }
          },
          headers: request_headers

    # Make a separate request to show page with headers
    get sign_app_configuration_email_url(user_email, ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "p", text: email_address
  end

  # ==========================================================================
  # Destroy Tests
  # ==========================================================================

  test "destroy removes email" do
    # Create two verified emails (need at least 2 to delete one)
    UserEmail.create!(
      address: "keep@example.com",
      user: @user,
      user_email_status_id: "VERIFIED_WITH_SIGN_UP"
    )
    email2 = UserEmail.create!(
      address: "delete@example.com",
      user: @user,
      user_email_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    delete sign_app_configuration_email_url(email2, ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_match %r{/configuration/emails}, response.location

    # Verify email was marked as deleted
    email2.reload
    assert_equal UserEmailStatus::DELETED, email2.user_email_status_id
  end

  test "destroy prevents deleting last email" do
    # Create only one verified email
    email = UserEmail.create!(
      address: "only@example.com",
      user: @user,
      user_email_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    delete sign_app_configuration_email_url(email, ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_equal I18n.t("sign.app.configuration.email.destroy.last_email"), flash[:alert]

    # Verify email was not deleted
    email.reload
    assert_equal "VERIFIED_WITH_SIGN_UP", email.user_email_status_id
  end

  test "destroy returns not found for non-existent email" do
    delete sign_app_configuration_email_url(id: "nonexistent", ri: "jp"), headers: request_headers

    assert_response :redirect
    assert_equal I18n.t("sign.app.configuration.email.destroy.not_found"), flash[:alert]
  end

  test "destroy does not allow deleting other user's email" do
    other_user = users(:two)
    email = UserEmail.create!(
      address: "other@example.com",
      user: other_user,
      user_email_status_id: "VERIFIED_WITH_SIGN_UP"
    )

    delete sign_app_configuration_email_url(email, ri: "jp"), headers: request_headers

    # Should not find the email since it belongs to another user
    assert_response :redirect
    assert_equal I18n.t("sign.app.configuration.email.destroy.not_found"), flash[:alert]
  end

  # ==========================================================================
  # Flow State Tests
  # ==========================================================================

  test "visiting index resets flow state" do
    # Start a flow
    post sign_app_configuration_emails_url(ri: "jp"),
         params: {
           user_email: { address: "flowreset@example.com" },
           "cf-turnstile-response": "test"
         },
         headers: request_headers

    # Visit index (should reset flow)
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    # Try to access edit directly (should fail due to reset flow)
    user_email = UserEmail.find_by(address: "flowreset@example.com")
    get edit_sign_app_configuration_email_url(user_email, ri: "jp"), headers: request_headers

    assert_response :redirect
  end

  # ==========================================================================
  # i18n Tests
  # ==========================================================================

  test "configuration email i18n keys exist" do
    keys = %w[
      sign.app.configuration.email.index.title
      sign.app.configuration.email.new.page_title
      sign.app.configuration.email.edit.title
      sign.app.configuration.email.show.title
      sign.app.configuration.email.create.verification_code_sent
      sign.app.configuration.email.update.success
      sign.app.configuration.email.destroy.success
      sign.app.configuration.email.destroy.last_email
    ]

    keys.each do |key|
      assert_not_nil I18n.t(key, locale: :ja, default: nil), "Missing ja translation for #{key}"
      assert_not_nil I18n.t(key, locale: :en, default: nil), "Missing en translation for #{key}"
    end
  end
end
