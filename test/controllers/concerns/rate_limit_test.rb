require "test_helper"

class RateLimitConcernTest < ActiveSupport::TestCase
  test "rate limit store memoizes redis cache" do
    assert_instance_of ActiveSupport::Cache::RedisCacheStore, RateLimit::RATE_LIMIT_STORE
    assert_same RateLimit::RATE_LIMIT_STORE, RateLimit::RATE_LIMIT_STORE
  end
end
