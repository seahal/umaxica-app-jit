# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    @host = ENV.fetch("SIGN_SERVICE_URL", "sign.app.localhost")
    @user = users(:one)
    # Clean up any existing tokens for this user
    UserToken.where(user: @user).delete_all
  end

  # Test: show without authentication redirects to login
  test "show without authentication redirects to login" do
    get sign_app_in_session_url(ri: "jp"),
        headers: browser_headers.merge("Host" => @host)

    assert_redirected_to new_sign_app_in_url(ri: "jp")
  end

  # Test: show with restricted session displays session management
  test "show with restricted session displays sessions" do
    # Create a restricted session
    token = create_restricted_session(@user)
    headers = as_user_headers_with_token(@user, token, host: @host)

    get sign_app_in_session_url(ri: "jp"), headers: headers

    assert_response :success
    assert_not response.redirect?
  end

  # Test: update without authentication redirects to login
  test "update without authentication redirects to login" do
    patch sign_app_in_session_url(ri: "jp"),
          params: { revoke_refs: ["some-ref"] },
          headers: browser_headers.merge("Host" => @host)

    assert_redirected_to new_sign_app_in_url(ri: "jp")
  end

  # Test: destroy without authentication redirects to login
  test "destroy without authentication redirects to login" do
    delete sign_app_in_session_url(ri: "jp"),
           headers: browser_headers.merge("Host" => @host)

    assert_redirected_to new_sign_app_in_url(ri: "jp")
  end

  # Test: destroy cancels restricted session and logs out
  test "destroy cancels restricted session and redirects to login" do
    token = create_restricted_session(@user)
    headers = as_user_headers_with_token(@user, token, host: @host)

    delete sign_app_in_session_url(ri: "jp"), headers: headers

    assert_redirected_to new_sign_app_in_url(ri: "jp")

    # Verify the session was revoked
    token.reload

    assert_not_nil token.expired_at
    assert_equal UserToken::STATUS_REVOKED, token.status
  end

  # Test: update revokes selected sessions
  test "update revokes selected sessions and promotes restricted session" do
    # Create 2 active sessions first
    active_token1 = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    active_token1.rotate_refresh_token!

    active_token2 = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    active_token2.rotate_refresh_token!

    # Create a restricted session (3rd session)
    restricted_token = UserToken.create!(user: @user, status: UserToken::STATUS_RESTRICTED)
    restricted_token.rotate_refresh_token!

    headers = as_user_headers_with_token(@user, restricted_token, host: @host)

    # Revoke one active session to make room
    patch sign_app_in_session_url(ri: "jp"),
          params: { revoke_refs: [active_token1.signed_ref] },
          headers: headers

    # The restricted session should be promoted to active
    restricted_token.reload

    assert_equal UserToken::STATUS_ACTIVE, restricted_token.status

    # The revoked session should be marked as revoked
    active_token1.reload

    assert_not_nil active_token1.expired_at
  end

  # Test: session promotion with valid Base64 rd param redirects to decoded URL
  test "update with rd param decodes Base64 and redirects to decoded path" do
    active_token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    active_token.rotate_refresh_token!

    restricted_token = UserToken.create!(user: @user, status: UserToken::STATUS_RESTRICTED)
    restricted_token.rotate_refresh_token!

    headers = as_user_headers_with_token(@user, restricted_token, host: @host)

    # Base64-encode a relative path as the rd param
    encoded_rd = Base64.urlsafe_encode64("/configuration")

    patch sign_app_in_session_url(ri: "jp", rd: encoded_rd),
          params: { revoke_refs: [active_token.signed_ref] },
          headers: headers

    restricted_token.reload

    assert_equal UserToken::STATUS_ACTIVE, restricted_token.status

    # Should redirect to the decoded path, not the raw Base64 string
    assert_response :redirect
    assert_match %r{/configuration}, response.location
    assert_no_match encoded_rd, response.location
  end

  # Test: session promotion with invalid rd param falls back to configuration path
  test "update with invalid rd param falls back to default path" do
    active_token = UserToken.create!(user: @user, status: UserToken::STATUS_ACTIVE)
    active_token.rotate_refresh_token!

    restricted_token = UserToken.create!(user: @user, status: UserToken::STATUS_RESTRICTED)
    restricted_token.rotate_refresh_token!

    headers = as_user_headers_with_token(@user, restricted_token, host: @host)

    # Pass an invalid Base64 string
    patch sign_app_in_session_url(ri: "jp", rd: "!!!invalid-base64!!!"),
          params: { revoke_refs: [active_token.signed_ref] },
          headers: headers

    restricted_token.reload

    assert_equal UserToken::STATUS_ACTIVE, restricted_token.status

    # Should fall back to default configuration path
    assert_response :redirect
    assert_match %r{/configuration}, response.location
  end

  # Test: active (non-restricted) session users are denied access to /in/session.
  # This page is ONLY for restricted session users (3rd login).
  # Active session access is an unexpected scenario, so we return 403 Forbidden.
  test "show with active session returns forbidden" do
    active_token = UserToken.create!(
      user: @user,
      status: UserToken::STATUS_ACTIVE,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )
    active_token.rotate_refresh_token!
    headers = as_user_headers_with_token(@user, active_token, host: @host)

    get sign_app_in_session_url(ri: "jp"), headers: headers

    assert_response :forbidden
  end

  test "update with active session returns forbidden" do
    active_token = UserToken.create!(
      user: @user,
      status: UserToken::STATUS_ACTIVE,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )
    active_token.rotate_refresh_token!
    headers = as_user_headers_with_token(@user, active_token, host: @host)

    patch sign_app_in_session_url(ri: "jp"),
          params: { revoke_refs: ["some-ref"] },
          headers: headers

    assert_response :forbidden
  end

  test "destroy with active session returns forbidden" do
    active_token = UserToken.create!(
      user: @user,
      status: UserToken::STATUS_ACTIVE,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )
    active_token.rotate_refresh_token!
    headers = as_user_headers_with_token(@user, active_token, host: @host)

    delete sign_app_in_session_url(ri: "jp"), headers: headers

    assert_response :forbidden
  end

  test "restricted session expires after 15 minutes and is locked on in/session" do
    token = create_restricted_session(@user, expires_at: 15.minutes.from_now)
    headers = as_user_headers_with_token(@user, token, host: @host)
    events = []

    travel 16.minutes do
      Rails.event.stub(
        :notify, lambda { |*args|
                   events << [args.first, args.last.is_a?(Hash) ? args.last : {}]
                 },
      ) do
        get sign_app_in_session_url(ri: "jp"), headers: headers
      end
    end

    assert_response :locked
    assert_equal "きんそくじこうです", response.body
    assert_not response.redirect?
    assert_includes events.map(&:first), "session.restricted.expired"
  end

  private

  def create_restricted_session(user, expires_at: nil)
    token = UserToken.create!(
      user: user,
      status: UserToken::STATUS_RESTRICTED,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
    )
    token.rotate_refresh_token!(expires_at: expires_at)
    token
  end

  def as_user_headers_with_token(user, token, host:)
    access_token = Auth::Base::Token.encode(user, host: host, session_public_id: token.public_id)
    browser_headers.merge(
      "Host" => host,
      "Authorization" => "Bearer #{access_token}",
      "Cookie" => "#{Auth::Base::ACCESS_COOKIE_KEY}=#{access_token}",
    )
  end
end
