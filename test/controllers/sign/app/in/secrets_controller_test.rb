# frozen_string_literal: true

require "test_helper"

class Sign::App::In::SecretsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @email = @user.user_emails.create!(address: "secret_login_#{SecureRandom.hex(4)}@example.com")
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    # Create a password secret for the user
    # Assuming UserSecret logic matches what's needed for verify_and_consume_secret
    # Since specific hashing logic isn't visible, we'll try to use the model's creation if possible,
    # or mock the behavior if needed.
    # However, for integration tests, relying on the real model is best.
    # We will create a UserSecret record.
    @password = "valid_password".freeze
    # Create a password secret for the user using the issue! method provided by Secret concern
    @user_secret, @password = UserSecret.issue!(
      name: "Login Password",
      user_id: @user.id,
      user_secret_kind_id: "UNLIMITED",
      uses: 100,
    )
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "should get new" do
    get new_sign_app_in_secret_url(ri: "jp"), headers: default_headers
    assert_response :success
  end

  test "should return unprocessable_content with invalid params" do
    post sign_app_in_secret_url(ri: "jp"),
         params: { secret_login_form: { account_identifiable_information: "", secret_value: "" } },
         headers: default_headers
    assert_response :unprocessable_content
  end

  test "resets session ID after successful secret (password) login" do
    # Ensure we have a session
    get new_sign_app_in_secret_url(ri: "jp"), headers: default_headers
    old_session_id = session.id

    # Attempt login
    post sign_app_in_secret_url(ri: "jp"),
         params: {
           secret_login_form: {
             account_identifiable_information: @email.address,
             secret_value: @password
           }
         },
         headers: default_headers

    assert_response :found, "Expected login to succeed and redirect"
    assert_not_nil session.id
    assert_not_equal old_session_id, session.id
  end

  private

    def default_headers
      {
        "Host" => ENV["SIGN_SERVICE_URL"] || "sign.app.localhost",
        "HTTPS" => "on",
        "cf-turnstile-response" => "test_token"
      }
    end
end
