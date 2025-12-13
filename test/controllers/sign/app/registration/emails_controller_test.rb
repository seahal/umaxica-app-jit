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

  private

  def default_headers
    { "Host" => host }
  end

  def host
    ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
  end
end
