# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceManagementFlowTest < ActionDispatch::IntegrationTest
  fixtures :user_statuses, :staff_statuses

  setup do
    @user = User.create!(
      status_id: UserStatus::NOTHING,
      public_id: "pf_#{SecureRandom.hex(4)}",
    )
    @user.user_emails.create!(
      address: "pref-flow-#{@user.public_id}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )
    @host = ENV.fetch("IDENTITY_SIGN_APP_URL", "sign.app.localhost")
  end

  test "preference cookie is created on first visit" do
    host! @host

    get identity.sign_app_preference_url(ri: "jp")

    assert_response :success
    cookie_name = preference_refresh_cookie_name

    assert_not_nil cookies[cookie_name], "Preference cookie should be set"
  end

  test "preference language update persists across requests" do
    host! @host

    get identity.sign_app_preference_url(ri: "jp")

    assert_response :success

    cookie_name = preference_refresh_cookie_name
    token = cookies[cookie_name]

    assert_not_nil token

    token_digest = SHA3::Digest::SHA3_384.digest(token.split(".", 2).last)
    pref = AppPreference.find_by(token_digest: token_digest)

    assert_not_nil pref

    original_language_id = pref.app_preference_language&.option_id

    get identity.edit_sign_app_preference_region_language_url(ri: "jp")

    assert_response :success

    patch identity.sign_app_preference_region_language_url(ri: "jp"),
          params: { preference_language: { option_id: "EN" } }

    assert_redirected_to identity.edit_sign_app_preference_region_language_url(ri: "jp")
    follow_redirect!

    assert_response :success

    pref.reload

    assert_not_equal original_language_id, pref.app_preference_language&.option_id
  end

  test "preference timezone update persists across requests" do
    host! @host

    get identity.sign_app_preference_url(ri: "jp")

    assert_response :success

    get identity.edit_sign_app_preference_region_timezone_url(ri: "jp")

    assert_response :success

    patch identity.sign_app_preference_region_timezone_url(ri: "jp"),
          params: { preference_timezone: { option_id: "Etc/UTC" } }

    assert_redirected_to identity.edit_sign_app_preference_region_timezone_url(ri: "jp")
    follow_redirect!

    assert_response :success
  end

  test "preference reset requires confirmation" do
    host! @host

    get identity.sign_app_preference_url(ri: "jp")

    assert_response :success

    get identity.edit_sign_app_preference_reset_url(ri: "jp")

    assert_response :success

    delete identity.sign_app_preference_reset_url(ri: "jp"), params: { confirm_reset: "0" }

    assert_response :unprocessable_content

    delete identity.sign_app_preference_reset_url(ri: "jp"), params: { confirm_reset: "1" }

    assert_redirected_to identity.edit_sign_app_preference_reset_url(ri: "jp")
  end

  private

  def preference_refresh_cookie_name
    Preference::CookieName.refresh
  end
end
