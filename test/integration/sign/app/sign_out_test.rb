# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::SignOutTest < ActionDispatch::IntegrationTest
  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = User.create!(status_id: UserStatus::ACTIVE)
    @email = UserEmail.create!(
      user: @user,
      address: "valid@example.com",
      user_email_status_id: "VERIFIED_WITH_SIGN_UP",
    )
    # Login manually
    post sign_app_in_secret_url(ri: "jp"), params: {
      secret_login_form: {
        account_identifiable_information: "valid@example.com",
        secret_value: "any_dummy_value_as_login_logic_is_bypassed_if_we_mock_or_use_helper",
      },
    }
    # Actually, we need to login properly.
    @password = SecureRandom.uuid
    @secret = @user.user_secrets.new(
      name: @password.first(4),
      user_secret_kind_id: UserSecretKind::UNLIMITED,
      user_secret_status_id: UserSecretStatus::ACTIVE,
    )
    @secret.password = @password
    @secret.save!
    CloudflareTurnstile.test_mode = true

    post sign_app_in_secret_url(ri: "jp"), params: {
      secret_login_form: {
        account_identifiable_information: "valid@example.com",
        secret_value: @password,
      },
    }

    assert_redirected_to sign_app_configuration_url(ri: "jp")
    @session_id = session.id
  end

  teardown do
    CloudflareTurnstile.test_mode = false
  end

  test "sign out clears session" do
    delete sign_app_out_url(ri: "jp")

    assert_redirected_to sign_app_root_path(ri: "jp")
    assert_not_equal @session_id, session.id
    # Ensure session is empty or changed
    cookie = cookies[Auth::Base::ACCESS_COOKIE_KEY]

    assert_predicate cookie, :blank?
  end
end
