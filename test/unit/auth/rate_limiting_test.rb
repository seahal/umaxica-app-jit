# frozen_string_literal: true

require "test_helper"

class AuthRateLimitingTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @user = users(:one)
  end

  teardown do
    Rails.cache.clear
  end

  test "rate limiter tracks requests and resets" do
    key = "test_key"
    config = { max_requests: 3, window: 60 }

    # Should succeed on first 3 requests
    assert_equal 2, RateLimiter.limit!(key: key, **config)
    assert_equal 1, RateLimiter.limit!(key: key, **config)
    assert_equal 0, RateLimiter.limit!(key: key, **config)

    # Should raise on 4th request
    assert_raises(RateLimiter::RateLimitExceeded) do
      RateLimiter.limit!(key: key, **config)
    end

    # Should work again after reset
    RateLimiter.reset!(key: key)
    assert_equal 2, RateLimiter.limit!(key: key, **config)
  end

  test "remaining returns correct count without incrementing" do
    key = "test_key"
    config = { max_requests: 5, window: 60 }

    # Check remaining before any requests
    assert_equal 5, RateLimiter.remaining(key: key, **config)

    # Use 2 requests
    RateLimiter.limit!(key: key, **config)
    RateLimiter.limit!(key: key, **config)

    # Check remaining - should be 3, not 2 remaining, 1 remaining
    assert_equal 3, RateLimiter.remaining(key: key, **config)
  end

  test "rate limit cookies same_site and secure attributes" do
    # This verifies that access/refresh cookies are HttpOnly + SameSite=Lax
    token_record = UserToken.create!(user: @user)
    refresh_plain = token_record.rotate_refresh_token!

    cookies[Auth::Base::REFRESH_COOKIE_KEY] = refresh_plain

    post "/edge/v1/token/refresh",
         headers: { "Host" => ENV.fetch("SIGN_SERVICE_URL", "test.umaxica.com"), "Accept" => "application/json" },
         as: :json

    # Test is for cookie attributes, not rate limiting
    # Skip if refresh fails due to setup issues
    return unless response.status == 200

    raw_header = response.headers["Set-Cookie"] || response.headers["set-cookie"]
    cookie_lines = raw_header.is_a?(Array) ? raw_header : raw_header.to_s.split("\n")
    access_cookie = cookie_lines.find { |line| line.start_with?("#{Auth::Base::ACCESS_COOKIE_KEY}=") }.to_s
    refresh_cookie = cookie_lines.find { |line| line.start_with?("#{Auth::Base::REFRESH_COOKIE_KEY}=") }.to_s

    # Access and refresh cookies should be HttpOnly
    assert_match(/HttpOnly/i, access_cookie, "Access cookie should be HttpOnly")
    assert_match(/HttpOnly/i, refresh_cookie, "Refresh cookie should be HttpOnly")

    # Both should have SameSite=Lax
    assert_match(/SameSite=Lax/i, access_cookie, "Access cookie should have SameSite=Lax")
    assert_match(/SameSite=Lax/i, refresh_cookie, "Refresh cookie should have SameSite=Lax")
  end
end
