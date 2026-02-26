# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::Configuration::SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses, :user_token_statuses, :user_token_kinds,
           :app_preference_activity_levels, :app_preference_activity_events

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV["SIGN_SERVICE_URL"] || "sign.app.localhost"
    @headers = as_user_headers(@user, host: @host)
  end

  test "index returns active sessions" do
    headers = as_user_headers(@user, host: @host, headers: { "Accept" => "application/json" })
    get sign_app_configuration_sessions_url(ri: "jp", format: :json), headers: headers

    assert_response :success
    assert response.parsed_body.key?("sessions")
  end

  test "destroy revokes session and returns see_other" do
    # Create a user token to revoke
    user_token = UserToken.create!(
      user_id: @user.id,
      public_id: "test_session_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )

    delete sign_app_configuration_session_url(user_token.public_id, ri: "jp"), headers: @headers

    assert_response :see_other

    user_token.reload

    assert_not_nil user_token.expired_at
  end

  test "requires authentication" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :redirect
  end

  test "others revokes active sessions except current session" do
    current_session_id = @headers["X-TEST-SESSION-PUBLIC-ID"]
    token_one = UserToken.create!(
      user_id: @user.id,
      public_id: "others_one_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )
    token_two = UserToken.create!(
      user_id: @user.id,
      public_id: "others_two_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )

    delete others_sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :see_other
    current_session = UserToken.find_by!(public_id: current_session_id)
    token_one.reload
    token_two.reload

    assert_nil current_session.expired_at
    assert_not_nil token_one.expired_at
    assert_not_nil token_two.expired_at
    assert_not response_has_cookie?(::Auth::Base::ACCESS_COOKIE_KEY)
    assert_not response_has_cookie?(::Auth::Base::REFRESH_COOKIE_KEY)
  end

  test "others requires authentication" do
    delete others_sign_app_configuration_sessions_url(ri: "jp"), headers: { "Host" => @host }

    assert_response :redirect
  end

  test "index shows revoke all other sessions button" do
    UserToken.create!(
      user_id: @user.id,
      public_id: "others_btn_#{SecureRandom.hex(4)}",
      refresh_expires_at: 1.day.from_now,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )

    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "form[action^='#{others_sign_app_configuration_sessions_path}']"
    assert_select "button", text: I18n.t("sign.app.configuration.sessions.revoke.others_button")
  end

  test "should show back link on index page" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
  end

  test "should show up link on index page" do
    get sign_app_configuration_sessions_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "a[href=?]", sign_app_configuration_path(ri: "jp")
  end
end
