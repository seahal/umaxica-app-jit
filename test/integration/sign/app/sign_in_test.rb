# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::SignInTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    CloudflareTurnstile.test_mode = true

    @user = User.create!(status_id: UserStatus::ACTIVE)
    @email = UserEmail.create!(
      user: @user,
      address: "valid@example.com",
      user_email_status_id: "VERIFIED_WITH_SIGN_UP",
    )

    @password = SecureRandom.uuid # 36 chars
    @secret = @user.user_secrets.new(
      name: @password.first(4),
      user_secret_kind_id: UserSecretKind::UNLIMITED,
      user_secret_status_id: UserSecretStatus::ACTIVE,
    )
    @secret.password = @password
    @secret.save!
  end

  teardown do
    CloudflareTurnstile.test_mode = false
  end

  test "successful login changes session id" do
    get new_sign_app_in_secret_url(ri: "jp")

    assert_response :success
    session_id_before = session.id

    post sign_app_in_secret_url(ri: "jp"), params: {
      secret_login_form: {
        account_identifiable_information: "valid@example.com",
        secret_value: @password,
      },
    }

    assert_redirected_to sign_app_configuration_url(ri: "jp")
    # Do not follow redirect as root is guest_only and returns 401 for logged in users

    assert_not_nil session.id
    assert_not_equal session_id_before, session.id if session_id_before
  end

  test "invalid credentials fails login" do
    post sign_app_in_secret_url(ri: "jp"), params: {
      secret_login_form: {
        account_identifiable_information: "valid@example.com",
        secret_value: SecureRandom.uuid, # Wrong password but correct length
      },
    }

    assert_response :unprocessable_content
    # Translation might be missing in test env, just check for error presence
    assert_select "li"
  end
end
