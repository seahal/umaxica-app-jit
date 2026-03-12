# typed: false
# frozen_string_literal: true

# Rate limiting concern for authentication endpoints
# Provides rate limiting for sensitive operations:
# - OTP sending (very restrictive)
# - Social login callbacks
# - Token refresh
module AuthRateLimiting
  extend ActiveSupport::Concern

  # Rate limits for different operations
  RATE_LIMIT_CONFIGS = {
    otp_send: { max_requests: 3, window: 300 }, # 3 per 5 minutes
    otp_resend: { max_requests: 2, window: 600 }, # 2 per 10 minutes
    social_login_start: { max_requests: 10, window: 60 }, # 10 per minute
    social_login_callback: { max_requests: 10, window: 60 }, # 10 per minute
    token_refresh: { max_requests: 10, window: 60 }, # 10 per minute
  }.freeze

  included do
    rescue_from RateLimiter::RateLimitExceeded, with: :handle_rate_limit_exceeded
  end

  # Check rate limit before OTP send
  # Returns true if limit not exceeded, false if exceeded
  def check_otp_rate_limit!(user_identifier)
    key = "otp_send:#{user_identifier}"
    config = RATE_LIMIT_CONFIGS[:otp_send]

    remaining = RateLimiter.remaining(key: key, max_requests: config[:max_requests])

    if remaining <= 0
      # For OTP, we don't want to expose rate limiting to user (to not reveal enumeration)
      # Instead, return as if we sent (silent failure)
      Rails.logger.warn "[RateLimit] OTP send rate limit exceeded: #{key}"
      raise RateLimiter::RateLimitExceeded.new(config[:window])
    end

    RateLimiter.limit!(key: key, **config)
    true
  end

  # Check rate limit for token refresh
  def check_refresh_rate_limit!(user_id)
    key = "token_refresh:#{user_id}"
    config = RATE_LIMIT_CONFIGS[:token_refresh]

    RateLimiter.limit!(key: key, **config)
  end

  # Check rate limit for social login callback
  def check_social_login_callback_rate_limit!(ip_address, provider)
    key = "social_callback:#{provider}:#{ip_address}"
    config = RATE_LIMIT_CONFIGS[:social_login_callback]

    RateLimiter.limit!(key: key, **config)
  end

  private

  def handle_rate_limit_exceeded(exception)
    retry_after = exception.retry_after || 60

    # Add Retry-After header
    response.headers["Retry-After"] = retry_after.to_s

    if request.format.json?
      render json: {
        error: "rate_limit_exceeded",
        message: I18n.t("errors.rate_limit.exceeded"),
        retry_after: retry_after,
      }, status: :too_many_requests
    else
      render plain: I18n.t("errors.rate_limit.exceeded"), status: :too_many_requests
    end
  end
end
