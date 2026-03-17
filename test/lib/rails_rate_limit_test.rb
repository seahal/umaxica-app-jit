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

  setup do
    RailsRateLimit::STORE_REGISTRY.clear
  end

  teardown do
    RailsRateLimit::STORE_REGISTRY.clear
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

  test "store returns default store" do
    store = RailsRateLimit.store

    assert_not_nil store
  end

  test "default namespace is rate_limit in production" do
    assert_equal "rate_limit", RailsRateLimit::DEFAULT_NAMESPACE
  end

  test "fail_mode defaults to open and downcases env value" do
    with_env("RATE_LIMIT_FAIL_MODE" => nil) do
      assert_equal "open", RailsRateLimit.fail_mode
    end

    with_env("RATE_LIMIT_FAIL_MODE" => "CLOSE") do
      assert_equal "close", RailsRateLimit.fail_mode
    end
  end

  test "fail_close? reflects fail mode" do
    with_env("RATE_LIMIT_FAIL_MODE" => "close") do
      assert_predicate RailsRateLimit, :fail_close?
    end
  end

  test "build_store returns null store when no redis url is configured" do
    with_env(
      "RATE_LIMIT_REDIS_URL" => nil,
      "REDIS_URL" => nil,
      "VALKEY_RAILS_RATE_LIMIT_URL" => nil,
      "VALKEY_RACK_ATTACK_URL" => nil,
    ) do
      store = RailsRateLimit.build_store

      assert_instance_of RailsRateLimit::NullStore, store
    end
  end

  test "build_store prefers explicit redis url and namespace" do
    built = nil
    store = Object.new

    with_env("RATE_LIMIT_REDIS_URL" => "redis://preferred", "RATE_LIMIT_NAMESPACE" => "custom:test") do
      RailsRateLimit::RedisStore.stub(
        :new, proc { |**kwargs|
                built = kwargs
                store
              },
      ) do
        assert_same store, RailsRateLimit.build_store
      end
    end

    assert_equal({ url: "redis://preferred", namespace: "custom:test" }, built)
  end

  test "build_store logs and falls back to null store when redis store init fails" do
    logged_message = nil

    with_env("RATE_LIMIT_REDIS_URL" => "redis://preferred") do
      Rails.logger.stub :error, ->(message) { logged_message = message } do
        RailsRateLimit::RedisStore.stub(:new, proc { |_args = nil, **_kwargs| raise StandardError, "boom" }) do
          store = RailsRateLimit.build_store

          assert_instance_of RailsRateLimit::NullStore, store
        end
      end
    end

    assert_includes logged_message, "store init failed"
  end

  test "store caches the built default store" do
    built_store = Object.new
    call_count = 0

    RailsRateLimit::STORE_REGISTRY.clear

    RailsRateLimit.stub :build_store, proc {
      call_count += 1
      built_store
    } do
      assert_same built_store, RailsRateLimit.store
      assert_same built_store, RailsRateLimit.store
    end

    assert_equal 1, call_count
  end

  test "default_namespace includes process id in test env" do
    assert_equal "rate_limit:test:#{Process.pid}", RailsRateLimit.default_namespace
  end

  private

  def with_env(vars)
    original = vars.transform_values { nil }
    vars.each_key { |key| original[key] = ENV[key] }

    vars.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    original.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end
  end
end
