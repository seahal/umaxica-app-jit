# typed: false
# frozen_string_literal: true

require "test_helper"

class RailsRateLimitTest < ActiveSupport::TestCase
  class MockRedis
    def initialize
      @data = {}
    end

    def ping
      "PONG"
    end

    def eval(_script, keys:, argv:)
      key = keys.first
      increment = argv[0].to_i
      ttl = argv[1].to_i

      current = @data[key] || 0
      @data[key] = current + increment
      @data["#{key}:expire"] = ttl

      @data[key]
    end

    def scan(_cursor, match:, count:)
      _count = count
      prefix = match.end_with?("*") ? match.delete_suffix("*") : match
      pattern_keys = @data.keys.select { |k| k.start_with?(prefix) }
      ["0", pattern_keys]
    end

    def del(*keys)
      keys.each { |k| @data.delete(k) }
    end

    def flushdb
      @data.clear
    end
  end

  test "RedisStore initializes with url and namespace" do
    mock_redis = MockRedis.new
    Redis.stub :new, mock_redis do
      store = RailsRateLimit::RedisStore.new(url: "redis://localhost:6379", namespace: "test")

      assert_equal "test", store.namespace
    end
  end

  test "RedisStore increments counter" do
    mock_redis = MockRedis.new
    Redis.stub :new, mock_redis do
      store = RailsRateLimit::RedisStore.new(url: "redis://localhost:6379", namespace: "test")

      result = store.increment("user:1", 1, expires_in: 60)

      assert_equal 1, result

      result = store.increment("user:1", 1, expires_in: 60)

      assert_equal 2, result
    end
  end

  test "RedisStore handles zero or negative ttl" do
    mock_redis = MockRedis.new
    Redis.stub :new, mock_redis do
      store = RailsRateLimit::RedisStore.new(url: "redis://localhost:6379", namespace: "test")

      result = store.increment("key", 1, expires_in: 0)

      assert_equal 1, result

      result = store.increment("key", 1, expires_in: -10)

      assert_equal 2, result
    end
  end

  test "RedisStore clear! deletes namespaced keys" do
    mock_redis = MockRedis.new
    Redis.stub :new, mock_redis do
      store = RailsRateLimit::RedisStore.new(url: "redis://localhost:6379", namespace: "test")

      store.increment("user:1", 1, expires_in: 60)
      store.increment("user:2", 1, expires_in: 60)

      store.clear!

      result = store.increment("user:1", 1, expires_in: 60)

      assert_equal 1, result
    end
  end

  test "RedisStore flushdb! clears all keys" do
    mock_redis = MockRedis.new
    Redis.stub :new, mock_redis do
      store = RailsRateLimit::RedisStore.new(url: "redis://localhost:6379", namespace: "test")

      store.increment("key1", 1, expires_in: 60)
      store.increment("key2", 1, expires_in: 60)

      store.flushdb!

      assert_nil mock_redis.instance_variable_get(:@data)["key1"]
      assert_nil mock_redis.instance_variable_get(:@data)["key2"]
    end
  end

  test "NullStore with fail_mode open returns 0" do
    store = RailsRateLimit::NullStore.new(fail_mode: "open")

    assert_equal 0, store.increment("key", 1, expires_in: 60)
  end

  test "NullStore with fail_mode close raises error" do
    store = RailsRateLimit::NullStore.new(fail_mode: "close")

    assert_raises(StandardError, "Rate limit store unavailable") do
      store.increment("key", 1, expires_in: 60)
    end
  end

  test "NullStore clear! returns nil" do
    store = RailsRateLimit::NullStore.new(fail_mode: "open")

    assert_nil store.clear!
  end
end
