# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthRateLimitingDummyController < ApplicationController
  include AuthRateLimiting

  def send_otp
    check_otp_rate_limit!(params[:user_id])
    render plain: "OTP sent"
  rescue RateLimiter::RateLimitExceeded
    # Silent failure - don't reveal rate limiting to user
    render plain: "OTP sent"
  end

  def refresh_token
    check_refresh_rate_limit!(params[:user_id])
    render plain: "Token refreshed"
  rescue RateLimiter::RateLimitExceeded => e
    handle_rate_limit_exceeded(e)
  end

  def social_callback
    check_social_login_callback_rate_limit!(request.remote_ip, params[:provider])
    render plain: "Callback processed"
  rescue RateLimiter::RateLimitExceeded => e
    handle_rate_limit_exceeded(e)
  end

  def exceeded_json
    error = RateLimiter::RateLimitExceeded.new(120)
    handle_rate_limit_exceeded(error)
  end

  def exceeded_html
    error = RateLimiter::RateLimitExceeded.new(120)
    request.format = :html
    handle_rate_limit_exceeded(error)
  end
end

class AuthRateLimitingConcernTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
  end

  teardown do
    Rails.cache.clear
  end

  test "OTP rate limit allows requests within limit" do
    with_routing do |set|
      set.draw do
        post "/send_otp", to: "auth_rate_limiting_dummy#send_otp"
      end

      3.times do |_i|
        post "/send_otp", params: { user_id: "user123" }
        assert_response :success
        assert_equal "OTP sent", response.body
      end
    end
  end

  test "OTP rate limit exceeds after max requests" do
    with_routing do |set|
      set.draw do
        post "/send_otp", to: "auth_rate_limiting_dummy#send_otp"
      end

      # Use up the limit
      3.times { post "/send_otp", params: { user_id: "user123" } }

      # Fourth request should still return success (silent failure)
      post "/send_otp", params: { user_id: "user123" }
      assert_response :success
      assert_equal "OTP sent", response.body
    end
  end

  test "OTP rate limit is per user" do
    with_routing do |set|
      set.draw do
        post "/send_otp", to: "auth_rate_limiting_dummy#send_otp"
      end

      # Use up limit for user1
      3.times { post "/send_otp", params: { user_id: "user1" } }

      # user2 should still be able to send OTPs
      post "/send_otp", params: { user_id: "user2" }
      assert_response :success
    end
  end

  test "token refresh rate limit works" do
    with_routing do |set|
      set.draw do
        post "/refresh", to: "auth_rate_limiting_dummy#refresh_token"
      end

      30.times do
        post "/refresh", params: { user_id: "user123" }
        assert_response :success
      end
    end
  end

  test "social login callback rate limit is per provider and IP" do
    with_routing do |set|
      set.draw do
        post "/social_callback", to: "auth_rate_limiting_dummy#social_callback"
      end

      10.times do
        post "/social_callback", params: { provider: "google" }, headers: { "REMOTE_ADDR" => "1.2.3.4" }
        assert_response :success
      end

      # Different provider should have separate limit
      10.times do
        post "/social_callback", params: { provider: "github" }, headers: { "REMOTE_ADDR" => "1.2.3.4" }
        assert_response :success
      end
    end
  end

  test "rate limit exceeded returns JSON response" do
    with_routing do |set|
      set.draw do
        get "/exceeded_json", to: "auth_rate_limiting_dummy#exceeded_json"
      end

      get "/exceeded_json", headers: { "Accept" => "application/json" }

      assert_response :too_many_requests
      assert_equal "120", response.headers["Retry-After"]

      body = response.parsed_body
      assert_equal "rate_limit_exceeded", body["error"]
      assert_equal 120, body["retry_after"]
    end
  end

  test "rate limit exceeded returns HTML response" do
    with_routing do |set|
      set.draw do
        get "/exceeded_html", to: "auth_rate_limiting_dummy#exceeded_html"
      end

      get "/exceeded_html"

      assert_response :too_many_requests
      assert_equal "120", response.headers["Retry-After"]
      assert_equal I18n.t("errors.rate_limit.exceeded"), response.body
    end
  end
end
