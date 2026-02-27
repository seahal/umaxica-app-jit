# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::Edge::V1::Token::RefreshesControllerTest < ActionDispatch::IntegrationTest
  fixtures :staffs, :staff_tokens, :staff_occurrence_statuses

  setup do
    @staff = staffs(:one)
    @host = ENV.fetch("SIGN_STAFF_URL", "test.umaxica.com")
    @device_id = SecureRandom.uuid
    @original_allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false
  end

  teardown do
    ActionController::Base.allow_forgery_protection = @original_allow_forgery_protection
  end

  test "POST refresh with valid refresh token sets both access and refresh cookies" do
    token_record = StaffToken.create!(staff: @staff, device_id: @device_id)
    refresh_plain = token_record.rotate_refresh_token!

    csrf_token = "test_csrf_token"
    cookies["jit_csrf_token"] = csrf_token
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain
    cookies[Auth::Base::DEVICE_COOKIE_KEY] = @device_id

    post "/edge/v1/token/refresh",
         headers: {
           "Host" => @host,
           "Accept" => "application/json",
           "X-CSRF-Token" => csrf_token,
         },
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
    token_record = StaffToken.create!(staff: @staff, device_id: @device_id)
    refresh_plain = token_record.rotate_refresh_token!

    csrf_token = "test_csrf_token"
    cookies["jit_csrf_token"] = csrf_token
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain
    cookies[Auth::Base::DEVICE_COOKIE_KEY] = @device_id

    post "/edge/v1/token/refresh",
         headers: {
           "Host" => @host,
           "Accept" => "application/json",
           "X-CSRF-Token" => csrf_token,
         },
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
    token_record = StaffToken.create!(staff: @staff, device_id: @device_id)
    old_refresh_plain = token_record.rotate_refresh_token!
    token_record.rotate_refresh_token!

    csrf_token = "test_csrf_token"
    cookies["jit_csrf_token"] = csrf_token
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = old_refresh_plain
    cookies[Auth::Base::DEVICE_COOKIE_KEY] = @device_id

    post "/edge/v1/token/refresh",
         headers: {
           "Host" => @host,
           "Accept" => "application/json",
           "X-CSRF-Token" => csrf_token,
         },
         as: :json

    assert_response :unauthorized
    json = response.parsed_body

    assert_equal "invalid_refresh_token", json["error_code"]
  end

  test "POST refresh denies when device_id missing and writes occurrence" do
    token_record = StaffToken.create!(staff: @staff, device_id: SecureRandom.uuid)
    refresh_plain = token_record.rotate_refresh_token!

    csrf_token = "test_csrf_token"
    cookies["jit_csrf_token"] = csrf_token
    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: {
           "Host" => @host,
           "Accept" => "application/json",
           "X-CSRF-Token" => csrf_token,
           "X-STRICT-DEVICE-CHECK" => "1",
         },
         as: :json

    assert_response :unauthorized
    occurrence = StaffOccurrence.order(:id).last

    assert_equal "refresh_device_missing", occurrence.event_type
    assert_equal 1, occurrence.status_id
    assert_equal "missing", occurrence.context["reason"]
    assert_predicate occurrence.context["request_id"], :present?
    assert_predicate occurrence.context["ip_hash"], :present?
  end
end
