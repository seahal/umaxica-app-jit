# frozen_string_literal: true

require "test_helper"

class Sign::Org::Edge::V1::Token::RefreshesControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_tokens

  setup do
    @staff = staffs(:one)
    @host = ENV.fetch("SIGN_STAFF_URL", "test.umaxica.com")
  end

  test "POST refresh with valid refresh token sets both access and refresh cookies" do
    token_record = StaffToken.create!(staff: @staff)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: { "Host" => @host, "Accept" => "application/json" },
         as: :json

    assert_response :ok

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

    json = response.parsed_body
    assert json["refreshed"]
  end

  test "GET check with valid access token from refresh returns 200" do
    token_record = StaffToken.create!(staff: @staff)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: { "Host" => @host, "Accept" => "application/json" },
         as: :json

    assert_response :ok

    response_cookies = extract_cookies_from_response
    cookies[Auth::Base::ACCESS_COOKIE_KEY] = response_cookies[Auth::Base::ACCESS_COOKIE_KEY]

    get "/edge/v1/token/check",
        headers: { "Host" => @host, "Accept" => "application/json" },
        as: :json

    assert_response :ok
    json = response.parsed_body
    assert json["authenticated"], "Staff should be authenticated"
  end

  test "POST refresh with old refresh token after rotation returns 401" do
    token_record = StaffToken.create!(staff: @staff)
    old_refresh_plain = token_record.rotate_refresh_token!
    token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = old_refresh_plain

    post "/edge/v1/token/refresh",
         headers: { "Host" => @host, "Accept" => "application/json" },
         as: :json

    assert_response :unauthorized
    json = response.parsed_body
    assert_equal "invalid_refresh_token", json["error_code"]
  end
end
