# frozen_string_literal: true

require "test_helper"
require "base64"

class Sign::App::ConfigurationsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_statuses

  setup do
    host! ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @headers = { "X-TEST-CURRENT-USER" => @user.id }.freeze
  end

  test "should get show when logged in" do
    get sign_app_configuration_url(ri: "jp"), headers: @headers

    assert_response :success
    assert_select "a[href^=?]", sign_app_configuration_emails_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_telephones_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_challenge_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_google_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_apple_path(ri: "jp")
    assert_select "a[href^=?]", sign_app_configuration_sessions_path(ri: "jp")
    assert_select "a[href^=?]", new_sign_app_configuration_withdrawal_path(ri: "jp")
    assert_select "a[href*=?]", edit_sign_app_configuration_out_path(ri: "jp"),
                  text: /#{Regexp.escape(I18n.t("sign.app.configuration.show.logout"))}/
    assert_select "a[href*=?]", sign_app_root_path(ri: "jp")
  end

  test "should redirect show when not logged in" do
    get sign_app_configuration_url(ri: "jp")
    assert_response :redirect
    target_path = new_sign_app_in_path
    assert_match %r{#{Regexp.escape(target_path)}\?.*ri=jp}, response.headers["Location"]
  end

  test "restricted session is blocked on configuration with locked plain response" do
    token = UserToken.create!(user: @user, status: UserToken::STATUS_RESTRICTED)
    token.rotate_refresh_token!(expires_at: 15.minutes.from_now)
    headers = as_user_headers(@user, host: @host).merge("X-TEST-SESSION-PUBLIC-ID" => token.public_id)

    get sign_app_configuration_url(ri: "jp"), headers: headers

    assert_response :locked
    assert_equal "きんそくじこうです", response.body
    assert_not response.redirect?
  end

  test "active session can access configuration normally" do
    token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    token.rotate_refresh_token!
    headers = as_user_headers(@user, host: @host).merge("X-TEST-SESSION-PUBLIC-ID" => token.public_id)

    get sign_app_configuration_url(ri: "jp"), headers: headers

    assert_response :success
  end

  test "should succeed with valid refresh cookie (transparent refresh)" do
    # Create a user token
    token = UserToken.create!(user_id: @user.id)
    refresh_plain = token.rotate_refresh_token!

    # Set only refresh cookie (no access token)
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    get sign_app_configuration_url(ri: "jp")

    # Should succeed (200) after transparent refresh, not redirect to /in/new
    assert_response :success
    assert_select "a[href^=?]", sign_app_configuration_emails_path(ri: "jp")
  end

  test "should not raise ReadOnlyError during transparent refresh" do
    # Create a user token
    token = UserToken.create!(user_id: @user.id)
    refresh_plain = token.rotate_refresh_token!

    # Set only refresh cookie
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    # Should not raise any ReadOnlyError
    assert_nothing_raised do
      get sign_app_configuration_url(ri: "jp")
    end

    assert_response :success
  end

  test "should succeed even when audit fails during transparent refresh" do
    # Create a user token
    token = UserToken.create!(user_id: @user.id)
    refresh_plain = token.rotate_refresh_token!

    # Set only refresh cookie
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    # Simulate audit failure by overriding record_audit to raise an error
    @controller.define_singleton_method(:record_audit) do |*_args|
      raise StandardError, "Simulated audit failure"
    end

    get sign_app_configuration_url(ri: "jp")

    # Should still succeed (200) - audit failure should not fail refresh
    assert_response :success
    assert_select "a[href^=?]", sign_app_configuration_emails_path(ri: "jp")
  end
end
