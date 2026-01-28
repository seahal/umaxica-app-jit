# frozen_string_literal: true

require "test_helper"

class Sign::App::SignUpTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    CloudflareTurnstile.test_mode = true
    @email = "newuser@example.com"
  end

  teardown do
    CloudflareTurnstile.test_mode = false
  end

  test "complete sign up flow" do
    # Step 1: Request Email Verification
    get new_sign_app_up_email_url(ri: "jp")
    assert_response :success

    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      perform_enqueued_jobs do
        post sign_app_up_emails_url(ri: "jp"), params: {
          user_email: { address: @email, confirm_policy: "1" }
        }
      end
    end

    user_email = UserEmail.find_by(address: @email)
    assert_not_nil user_email
    assert_redirected_to edit_sign_app_up_email_url(user_email, ri: "jp")

    # Step 2: Verify OTP
    follow_redirect!
    assert_response :success

    # Generate the expected code from the model directly
    user_email.reload
    hotp = ROTP::HOTP.new(user_email.otp_private_key)
    code = hotp.at(user_email.otp_counter.to_i)

    assert_not_nil code

    # Step 3: Submit OTP
    patch sign_app_up_email_url(user_email, ri: "jp"), params: {
      user_email: { pass_code: code },
      id: user_email.public_id
    }

    assert_redirected_to sign_app_configuration_path(ri: "jp")
    follow_redirect!
    assert_response :success

    # Verify user is created and logged in
    user = UserEmail.find_by(address: @email).user
    assert_not_nil user
    assert_equal "VERIFIED_WITH_SIGN_UP", user.status_id
    assert_not_nil session[Auth::Base::ACCESS_COOKIE_KEY] || cookies[Auth::Base::ACCESS_COOKIE_KEY]
  end

  test "sign up validation errors" do
    post sign_app_up_emails_url(ri: "jp"), params: {
      user_email: { address: "", confirm_policy: "0" } # Invalid
    }
    assert_response :unprocessable_content
  end
end
