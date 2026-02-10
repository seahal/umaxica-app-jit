# frozen_string_literal: true

require "test_helper"

class Sign::App::Edge::V1::Token::RefreshesControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :user_tokens

  setup do
    @user = users(:one)
    @host = ENV.fetch("SIGN_SERVICE_URL", "test.umaxica.com")
    @csrf_token = nil
  end

  test "POST refresh with valid refresh token sets both access and refresh cookies" do
    # Create a token record and generate a refresh token
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    # Set the refresh cookie
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :ok

    # Verify Set-Cookie headers contain both access and refresh cookies
    assert response_has_cookie?(Auth::Base::ACCESS_COOKIE_KEY),
           "Response should set access cookie (#{Auth::Base::ACCESS_COOKIE_KEY})"
    assert response_has_cookie?(Auth::Base::REFRESH_COOKIE_KEY),
           "Response should set refresh cookie (#{Auth::Base::REFRESH_COOKIE_KEY})"

    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    cookie_lines = raw_header.is_a?(Array) ? raw_header : raw_header.to_s.split("\n")
    access_cookie = cookie_lines.find { |line| line.start_with?("#{Auth::Base::ACCESS_COOKIE_KEY}=") }.to_s
    refresh_cookie = cookie_lines.find { |line| line.start_with?("#{Auth::Base::REFRESH_COOKIE_KEY}=") }.to_s
    assert_match(/samesite=lax/i, access_cookie)
    assert_match(/samesite=lax/i, refresh_cookie)

    # Verify JSON response indicates success
    json = response.parsed_body
    assert json["refreshed"]
  end

  test "GET check with valid access token from refresh returns 200" do
    # Create a token record and generate tokens
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    # Set the refresh cookie
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    # First, refresh to get new tokens
    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :ok

    # Extract cookies from Set-Cookie response header
    response_cookies = extract_cookies_from_response

    # Set the new access cookie for the next request
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = response_cookies[Auth::Base::ACCESS_COOKIE_KEY]

    # Now check should succeed
    get "/edge/v1/token/check",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :ok
    json = response.parsed_body
    assert json["authenticated"], "User should be authenticated"
  end

  test "POST refresh with old refresh token after rotation returns 401" do
    # Create a token record and generate a refresh token
    token_record = UserToken.create!(user: @user)
    old_refresh_plain = token_record.rotate_refresh_token!

    # Simulate rotation by calling rotate again (as if another refresh happened)
    token_record.rotate_refresh_token!

    # Try to use the old refresh token
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = old_refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :unauthorized
    json = response.parsed_body
    assert_equal "invalid_refresh_token", json["error_code"]
  end

  test "GET check with invalid access token returns 401" do
    # Set an invalid access token
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = "invalid.jwt.token"

    get "/edge/v1/token/check",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :unauthorized
    json = response.parsed_body
    assert_not json["authenticated"]
  end

  test "GET check without access token returns 401" do
    get "/edge/v1/token/check",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :unauthorized
    json = response.parsed_body
    assert_not json["authenticated"]
  end

  test "POST refresh with missing refresh token returns 400" do
    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :bad_request
    json = response.parsed_body
    assert_equal "missing_refresh_token", json["error_code"]
  end

  test "POST refresh with expired refresh token returns 401" do
    # Create a token record with expired refresh
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!(expires_at: 1.day.ago)

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :unauthorized
  end

  test "POST refresh with revoked token returns 401" do
    # Create a token record and revoke it
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!
    token_record.revoke!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :unauthorized
  end

  test "POST refresh with restricted token returns 403 and does not rotate token" do
    token_record = UserToken.create!(user: @user, status: UserToken::STATUS_RESTRICTED)
    refresh_plain = token_record.rotate_refresh_token!(expires_at: 15.minutes.from_now)
    before_generation = token_record.refresh_token_generation
    before_digest = token_record.refresh_token_digest

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :forbidden
    json = response.parsed_body
    assert_equal "restricted_session", json["error_code"]

    token_record.reload
    assert_equal before_generation, token_record.refresh_token_generation
    assert_equal before_digest, token_record.refresh_token_digest
  end

  test "refresh cookie is not encrypted (plain value)" do
    # Create a token record and generate a refresh token
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    # Set the refresh cookie
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: true),
         as: :json

    assert_response :ok

    response_cookies = extract_cookies_from_response
    cookie_refresh_token = CGI.unescape(response_cookies[Auth::Base::REFRESH_COOKIE_KEY].to_s)

    # The cookie value should start with the public_id (same format as JSON response)
    assert_includes cookie_refresh_token, token_record.public_id,
                    "Cookie should contain the public_id prefix"
    assert_includes cookie_refresh_token, ".", "Refresh cookie should be in public_id.verifier format"
  end

  test "access cookie uses correct TTL" do
    # Create a token record and generate a refresh token
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    freeze_time do
      post "/edge/v1/token/refresh",
           headers: json_headers(with_csrf: true),
           as: :json

      assert_response :ok

      # Check the expires attribute of the access cookie
      expiry = response_cookie_expiry(Auth::Base::ACCESS_COOKIE_KEY)
      assert_not_nil expiry, "Access cookie should have expires attribute"

      # Should be approximately 1 hour from now (within a few seconds tolerance)
      expected_expiry = Auth::Base::ACCESS_TOKEN_TTL.from_now
      assert_in_delta expected_expiry.to_i, expiry.to_i, 5,
                      "Access cookie expiry should be ~1 hour from now"
    end
  end

  test "POST refresh without CSRF token returns 403" do
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: json_headers(with_csrf: false),
         as: :json

    assert_response :forbidden
    json = response.parsed_body
    assert_equal "invalid_csrf_token", json["error"]
  end

  private

  def json_headers(with_csrf:)
    headers = { "Host" => @host, "Accept" => "application/json" }
    headers["X-CSRF-Token"] = csrf_token if with_csrf
    headers
  end

  def csrf_token
    @csrf_token ||=
      begin
        get "/edge/v1/csrf",
            params: { ri: "jp" },
            headers: { "Host" => @host, "Accept" => "application/json" },
            as: :json
        assert_response :ok
        response.parsed_body.fetch("csrf_token")
      end
  end
end
