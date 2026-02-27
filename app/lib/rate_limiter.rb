# typed: false
# frozen_string_literal: true

# Simple rate limiting using Rails.cache
# Can be easily swapped to Redis by changing cache store
#
# Usage:
#   RateLimiter.limit!(
#     key: "otp_send:#{user_id}",
#     max_requests: 5,
#     window: 60  # seconds
#   )
#
# Raises RateLimitExceeded if limit exceeded
class RateLimiter
  class RateLimitExceeded < StandardError
    attr_reader :retry_after

    def initialize(retry_after = nil)
      @retry_after = retry_after
      super("Rate limit exceeded")
    end
  end

  # Check and increment rate limit counter
  # Returns remaining requests, raises RateLimitExceeded if limit Hit
  def self.limit!(key:, max_requests: 20, window: 60)
    cache_key = "rate_limit:#{key}"
    current = (Rails.cache.read(cache_key) || 0).to_i

    if current >= max_requests
      # Recalculate TTL for retry-after
      ttl = Rails.cache.read("#{cache_key}:ttl") || window
      raise RateLimitExceeded.new(ttl)
    end

    # Increment counter
    new_count = current + 1
    Rails.cache.write(cache_key, new_count, expires_in: window.seconds)
    Rails.cache.write("#{cache_key}:ttl", window, expires_in: window.seconds)

    max_requests - new_count # remaining
  end

  # Get remaining requests without incrementing
  def self.remaining(key:, max_requests: 20)
    cache_key = "rate_limit:#{key}"
    current = (Rails.cache.read(cache_key) || 0).to_i
    [max_requests - current, 0].max
  end

  # Reset rate limit for a key
  def self.reset!(key:)
    cache_key = "rate_limit:#{key}"
    Rails.cache.delete(cache_key)
    Rails.cache.delete("#{cache_key}:ttl")
  end
end
