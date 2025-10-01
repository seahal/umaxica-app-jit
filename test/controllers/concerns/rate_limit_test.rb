# frozen_string_literal: true

require "test_helper"

class RateLimitConcernTest < ActiveSupport::TestCase
  test "configures rate limiting when included" do
    stub_controller = Class.new do
      class << self
        attr_reader :rate_limit_args
      end

      def self.rate_limit(**kwargs)
        @rate_limit_args = kwargs
      end

      include RateLimit
    end

    assert_equal 1000, stub_controller.rate_limit_args[:to]
    assert_equal 1.hour, stub_controller.rate_limit_args[:within]
    assert_same RateLimit::RATE_LIMIT_STORE, stub_controller.rate_limit_args[:store]
  end

  test "rate limit store memoizes redis cache" do
    assert_instance_of ActiveSupport::Cache::RedisCacheStore, RateLimit::RATE_LIMIT_STORE
    assert_same RateLimit::RATE_LIMIT_STORE, RateLimit::RATE_LIMIT_STORE
  end
end
