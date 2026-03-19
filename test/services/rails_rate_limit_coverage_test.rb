# typed: false
# frozen_string_literal: true

require "test_helper"
require Rails.root.join("app/lib/rails_rate_limit")

class RailsRateLimitCoverageTest < ActiveSupport::TestCase
  class MockRedis
    def initialize
      @data = {}
    end

    def ping
      "PONG"
    end

    def eval(_script, keys:, argv:)
      key = keys.first
      amount = argv[0].to_i
      ttl = argv[1].to_i
      @data[key] = (@data[key] || 0) + amount
      @data["#{key}:expire"] = ttl
      @data[key]
    end

    def scan(_cursor, match:, count:)
      _count = count
      prefix = match.delete_suffix("*")
      ["0", @data.keys.select { |key| key.start_with?(prefix) }]
    end

    def del(*keys)
      keys.each { |key| @data.delete(key) }
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

  test "redis and null stores exercise supported paths" do
    Redis.stub :new, MockRedis.new do
      store = RailsRateLimit::RedisStore.new(url: "redis://localhost:6379", namespace: "test")

      assert_equal 1, store.increment("user:1", 1, expires_in: 0)
      assert_equal 2, store.increment("user:1", 1, expires_in: 60)
      store.clear!
      store.flushdb!
    end

    assert_equal "open", RailsRateLimit.fail_mode
    assert_equal "rate_limit:test:#{Process.pid}", RailsRateLimit.default_namespace
    assert_equal 0, RailsRateLimit::NullStore.new(fail_mode: "open").increment("key", 1, expires_in: 60)

    with_env(
      "RATE_LIMIT_REDIS_URL" => nil,
      "REDIS_URL" => nil,
      "VALKEY_RAILS_RATE_LIMIT_URL" => nil,
      "VALKEY_RACK_ATTACK_URL" => nil,
    ) do
      assert_instance_of RailsRateLimit::NullStore, RailsRateLimit.build_store
    end
  end

  test "store uses configured redis store and falls back on init failures" do
    built = nil
    fake_store = Object.new

    with_env("RATE_LIMIT_REDIS_URL" => "redis://preferred", "RATE_LIMIT_NAMESPACE" => "custom:test") do
      RailsRateLimit::RedisStore.stub(
        :new, proc { |**kwargs|
                built = kwargs
                fake_store
              },
      ) do
        assert_same fake_store, RailsRateLimit.build_store
      end
    end

    assert_equal({ url: "redis://preferred", namespace: "custom:test" }, built)

    logged_message = nil
    with_env("RATE_LIMIT_REDIS_URL" => "redis://preferred", "RATE_LIMIT_FAIL_MODE" => "close") do
      Rails.logger.stub :error, ->(message) { logged_message = message } do
        RailsRateLimit::RedisStore.stub(:new, proc { |_args = nil, **_kwargs| raise StandardError, "boom" }) do
          assert_instance_of RailsRateLimit::NullStore, RailsRateLimit.build_store
          assert_predicate RailsRateLimit, :fail_close?
        end
      end
    end

    assert_includes logged_message, "store init failed"
  end

  private

  def with_env(vars)
    original = {}
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
