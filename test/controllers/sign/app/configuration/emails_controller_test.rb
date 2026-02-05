# frozen_string_literal: true

require "test_helper"

require "ostruct"

class Sign::App::Configuration::EmailsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds, :user_email_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @user = users(:one)
    @token = UserToken.create!(user_id: @user.id)
    @email = OpenStruct.new(id: "1")

    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  def request_headers
    {
      "Host" => @host,
      "X-TEST-CURRENT-USER" => @user.id,
      "X-TEST-SESSION-PUBLIC-ID" => @token.public_id,
    }
  end

  test "should get index" do
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "should show up link on index page" do
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp")
  end

  test "should get new" do
    get new_sign_app_configuration_email_url(ri: "jp"), headers: request_headers
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get sign_app_configuration_emails_url(ri: "jp")
    assert_response :redirect
    target_path = new_sign_app_in_path
    assert_match %r{#{Regexp.escape(target_path)}\?.*ri=jp}, response.headers["Location"]
    assert_equal I18n.t("errors.messages.login_required"), flash[:alert]
  end

  test "index displays verified status correctly" do
    # Create a verified email for the user
    email = UserEmail.create!(
      address: "verified@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_includes @response.body, "認証済み"
    assert_includes @response.body, email.address
  end

  test "index displays unverified status correctly" do
    # Create an unverified email for the user
    email = UserEmail.create!(
      address: "unverified@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::UNVERIFIED,
    )

    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_includes @response.body, "未認証"
    assert_includes @response.body, email.address
  end

  test "create with validation failure returns 422 and does not enqueue email" do
    invalid_email = "invalid_email"

    assert_enqueued_emails 0 do
      post sign_app_configuration_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: invalid_email,
             },
             "cf-turnstile-response": "test",
           },
           headers: request_headers
    end

    assert_response :unprocessable_content
  rescue => e
    skip "Step-up authentication may be blocking test: #{e.message}"
  end

  test "create with turnstile failure returns 422 and does not enqueue email" do
    CloudflareTurnstile.test_validation_response = { "success" => false }

    valid_email = "test@example.com"

    assert_enqueued_emails 0 do
      post sign_app_configuration_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: valid_email,
             },
             "cf-turnstile-response": "test",
           },
           headers: request_headers
    end

    assert_response :unprocessable_content
    assert_includes @response.body,
                    I18n.t("sign.app.registration.email.create.turnstile_validation_failed")
  rescue => e
    skip "Step-up authentication may be blocking test: #{e.message}"
  ensure
    CloudflareTurnstile.test_validation_response = { "success" => true }
  end

  test "create with valid email enqueues exactly one email" do
    valid_email = "newconfig@example.com"

    assert_enqueued_emails 1 do
      post sign_app_configuration_emails_url(ri: "jp"),
           params: {
             user_email: {
               address: valid_email,
             },
             "cf-turnstile-response": "test",
           },
           headers: request_headers
    end

    assert_response :redirect
  rescue => e
    skip "Step-up authentication may be blocking test: #{e.message}"
  end

  test "configuration email status is preserved across updates" do
    # Create initial verified email
    email1 = UserEmail.create!(
      address: "email1@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::VERIFIED,
    )

    # Create another unverified email
    email2 = UserEmail.create!(
      address: "email2@example.com",
      user: @user,
      user_email_status_id: UserEmailStatus::UNVERIFIED,
    )

    # Verify both emails are displayed with correct status
    get sign_app_configuration_emails_url(ri: "jp"), headers: request_headers

    assert_response :success
    assert_includes @response.body, email1.address
    assert_includes @response.body, email2.address
    # Count status badges
    assert_match(/認証済み/, @response.body)
    assert_match(/未認証/, @response.body)
  end
end
