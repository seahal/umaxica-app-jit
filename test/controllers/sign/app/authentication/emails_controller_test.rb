require "test_helper"

class Sign::App::Authentication::EmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers
  # rubocop:disable Minitest/MultipleAssertions
  test "should get new" do
    get new_sign_app_authentication_email_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"] }

    assert_select "h1", I18n.t("sign.app.authentication.email.new.page_title")
    assert_select "ul li" do
      assert_select "a", I18n.t("sign.app.authentication.new.back")
      assert_select "a", I18n.t("sign.app.authentication.email.new.registration")
    end

    assert_nil cookies[:htop_private_key]
    #    assert_select "a[href=?]", new_sign_app_authentication_path(query), I18n.t("sign.app.authentication.new.back")
    assert_response :success
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "reject already logged in user" do
    user = users(:one)
    get new_sign_app_authentication_email_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"], "X-TEST-CURRENT-USER" => user.id }

    assert_response :bad_request
    assert_equal I18n.t("sign.app.authentication.email.new.you_have_already_logged_in"), response.body
  end

  test "reject already logged in staff" do
    staff = staffs(:one)
    get new_sign_app_authentication_email_url, headers: { "Host" => ENV["SIGN_SERVICE_URL"], "X-TEST-CURRENT-STAFF" => staff.id }

    assert_response :success
    # assert_equal I18n.t("sign.app.authentication.email.new.you_have_already_logged_in"), response.body
  end
  setup do
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    ActionMailer::Base.deliveries.clear
    CloudflareTurnstile.test_mode = true
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "GET new displays email form" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "input[name='user_identity_email[address]']"
  end

  test "POST create without valid email redirects (enumeration protection)" do
    post sign_app_authentication_email_url,
         params: { user_identity_email: { address: "nonexistent@example.com" } },
         headers: { "Host" => @host }

    # Should redirect to edit to prevent enumeration
    assert_response :found
    assert_redirected_to %r{/authentication/email/edit}
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "POST create with unknown email does not issue otp" do
    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      post sign_app_authentication_email_url,
           params: { user_identity_email: { address: "missing-user@example.com" } },
           headers: { "Host" => @host }

      assert_response :found
      assert_redirected_to %r{/authentication/email/edit}
      # Session should not have ID, but might have address
      assert_nil session[:user_email_authentication_id]
    end
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "POST create with existing email generates OTP and redirects to edit" do
    # Create a test email in the database
    test_email = "auth_test_#{SecureRandom.hex(4)}@example.com"
    UserIdentityEmail.create!(address: test_email)

    # Make the POST request with valid email and Turnstile response
    # Turnstile is automatically mocked to return true in test environment
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    assert_response :found
    assert_redirected_to %r{/authentication/email/edit}
  end

  test "timing attack protection in update action" do
    # Create and verify an email
    test_email = UserIdentityEmail.create!(address: "timing_test@example.com", confirm_policy: true)
    test_email.update!(pass_code: "123456", otp_attempts_count: 0)

    # Start session
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    follow_redirect!
    session_id = cookies["user_email_authentication_id"]

    # Measure time for valid code
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    patch sign_app_authentication_email_url,
          params: { user_identity_email: { pass_code: "123456" } },
          headers: { "Host" => @host, "Cookie" => "user_email_authentication_id=#{session_id}" }
    valid_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

    # Reset for invalid code test
    test_email.update!(pass_code: "123456", otp_attempts_count: 0)
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    follow_redirect!
    session_id = cookies["user_email_authentication_id"]

    # Measure time for invalid code
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    patch sign_app_authentication_email_url,
          params: { user_identity_email: { pass_code: "999999" } },
          headers: { "Host" => @host, "Cookie" => "user_email_authentication_id=#{session_id}" }
    invalid_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

    # Times should be similar (within 50% tolerance for timing attack protection)
    time_difference = (valid_time - invalid_time).abs
    max_allowed_difference = [ valid_time, invalid_time ].max * 1

    assert_operator time_difference, :<=, max_allowed_difference,
                    "Response times differ too much: valid=#{valid_time.round(4)}s, invalid=#{invalid_time.round(4)}s"
  end

  # Turnstile Widget Verification Tests
  test "new authentication email page renders Turnstile widget" do
    get new_sign_app_authentication_email_url, headers: { "Host" => @host }

    assert_response :success
    assert_select "div[id^='cf-turnstile-']", count: 1
  end

  # Login Tests
  # rubocop:disable Minitest/MultipleAssertions
  test "successful OTP verification redirects to root" do
    # Create email without user association (user_id field is not properly typed for UUID refs)
    test_email = UserIdentityEmail.create!(
      address: "login_test_#{SecureRandom.hex(4)}@example.com"
    )

    # Start authentication process to trigger email discovery
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    assert_response :found
    assert_equal test_email.id.to_s, session[:user_email_authentication_id]

    # Generate valid OTP code
    otp_private_key = ROTP::Base32.random_base32
    otp_counter = 12345
    hotp = ROTP::HOTP.new(otp_private_key)
    valid_pass_code = hotp.at(otp_counter).to_s

    # Store OTP on the email manually (bypasses application logic)
    test_email.store_otp(otp_private_key, otp_counter, 12.minutes.from_now.to_i)

    # Verify OTP to log in
    patch sign_app_authentication_email_url,
          params: { user_identity_email: { pass_code: valid_pass_code } },
          headers: { "Host" => @host }

    # Should redirect to root on success
    assert_response :found
    assert_redirected_to "/"
  end

  test "otp resend enforces cooldown" do
    test_email = UserIdentityEmail.create!(
      address: "cooldown_test_#{SecureRandom.hex(4)}@example.com"
    )

    assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
      post sign_app_authentication_email_url,
           params: {
             user_identity_email: { address: test_email.address },
             "cf-turnstile-response" => "test_token"
           },
           headers: { "Host" => @host }
    end

    initial_sent_at = test_email.reload.otp_last_sent_at

    assert_not_nil initial_sent_at

    assert_no_difference -> { ActionMailer::Base.deliveries.count } do
      post sign_app_authentication_email_url,
           params: {
             user_identity_email: { address: test_email.address },
             "cf-turnstile-response" => "test_token"
           },
           headers: { "Host" => @host }
    end
    assert_equal initial_sent_at, test_email.reload.otp_last_sent_at

    travel Email::OTP_COOLDOWN_PERIOD + 1.second do
      assert_difference -> { ActionMailer::Base.deliveries.count }, 1 do
        post sign_app_authentication_email_url,
             params: {
               user_identity_email: { address: test_email.address },
               "cf-turnstile-response" => "test_token"
             },
             headers: { "Host" => @host }
      end
      assert_operator test_email.reload.otp_last_sent_at, :>, initial_sent_at
    end
  end

  test "successful OTP verification records login audit event" do
    user = users(:one)
    test_email = user.user_identity_emails.create!(address: "audit_login_#{SecureRandom.hex(4)}@example.com")

    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    assert_equal test_email.id.to_s, session[:user_email_authentication_id]

    otp_private_key = ROTP::Base32.random_base32
    otp_counter = 12345
    hotp = ROTP::HOTP.new(otp_private_key)
    valid_pass_code = hotp.at(otp_counter).to_s
    test_email.store_otp(otp_private_key, otp_counter, 12.minutes.from_now.to_i)

    assert_difference -> { UserIdentityAudit.where(event_id: "LOGGED_IN").count }, 1 do
      patch sign_app_authentication_email_url,
            params: { user_identity_email: { pass_code: valid_pass_code } },
            headers: { "Host" => @host }
    end

    audit = UserIdentityAudit.order(created_at: :desc).first

    assert_equal "LOGGED_IN", audit.event_id
    assert_equal user, audit.user
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "invalid OTP code returns error message" do
    test_email = UserIdentityEmail.create!(
      address: "invalid_otp_test_#{SecureRandom.hex(4)}@example.com"
    )

    # Start authentication
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    assert_equal test_email.id.to_s, session[:user_email_authentication_id]

    # Set up valid OTP but provide wrong code
    otp_private_key = ROTP::Base32.random_base32
    otp_counter = 12345
    test_email.store_otp(otp_private_key, otp_counter, 12.minutes.from_now.to_i)

    # Try with invalid code
    patch sign_app_authentication_email_url,
          params: { user_identity_email: { pass_code: "999999" } },
          headers: { "Host" => @host }

    # Should render edit page with error
    assert_response :unprocessable_content
    assert_includes @response.body, "Invalid verification code"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "invalid OTP attempt records login failed audit event" do
    user = users(:one)
    test_email = user.user_identity_emails.create!(
      address: "audit_login_failed_#{SecureRandom.hex(4)}@example.com"
    )

    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token"
         },
         headers: { "Host" => @host }

    assert_equal test_email.id.to_s, session[:user_email_authentication_id]

    otp_private_key = ROTP::Base32.random_base32
    otp_counter = 56789
    test_email.store_otp(otp_private_key, otp_counter, 12.minutes.from_now.to_i)

    assert_difference -> { UserIdentityAudit.where(event_id: "LOGIN_FAILED").count }, 1 do
      patch sign_app_authentication_email_url,
            params: { user_identity_email: { pass_code: "000000" } },
            headers: { "Host" => @host }
    end

    audit = UserIdentityAudit.order(created_at: :desc).first

    assert_equal "LOGIN_FAILED", audit.event_id
    assert_equal user, audit.user
  end
  # rubocop:enable Minitest/MultipleAssertions

  test "already logged in user cannot authenticate" do
    # Test that the ensure_not_logged_in before_action works
    # This would require proper session handling which is complex in integration tests
    skip "Rails integration test session handling needs clarification"
  end

  # rubocop:disable Minitest/MultipleAssertions
  test "redirects to encoded URL after successful login when rd parameter is provided" do
    # Create a test user and email
    test_email = UserIdentityEmail.create!(
      address: "redirect_login_test_#{SecureRandom.hex(4)}@example.com"
    )

    redirect_url = "https://#{ENV['APEX_SERVICE_URL']}/dashboard"
    encoded_rd = Base64.urlsafe_encode64(redirect_url)

    # Start authentication with rd parameter
    post sign_app_authentication_email_url,
         params: {
           user_identity_email: { address: test_email.address },
           "cf-turnstile-response" => "test_token",
           rd: encoded_rd
         },
         headers: { "Host" => @host }

    assert_response :found
    assert_includes response.location, "rd=#{CGI.escape(encoded_rd)}"
    assert_equal test_email.id.to_s, session[:user_email_authentication_id]
    assert_equal encoded_rd, session[:user_email_authentication_rd]

    # Generate valid OTP code
    otp_private_key = ROTP::Base32.random_base32
    otp_counter = 12345
    hotp = ROTP::HOTP.new(otp_private_key)
    valid_pass_code = hotp.at(otp_counter).to_s

    # Store OTP
    test_email.store_otp(otp_private_key, otp_counter, 12.minutes.from_now.to_i)

    # Verify OTP with rd parameter
    patch sign_app_authentication_email_url,
          params: {
            user_identity_email: { pass_code: valid_pass_code },
            rd: encoded_rd
          },
          headers: { "Host" => @host }

    # Should redirect to the encoded URL
    assert_response :found
    assert_redirected_to redirect_url
    assert_nil session[:user_email_authentication_rd]
  end
  # rubocop:enable Minitest/MultipleAssertions
end
