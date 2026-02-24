# typed: false
# frozen_string_literal: true

require "concurrent/map"

module RailsRateLimit
  DEFAULT_NAMESPACE = "rate_limit"
  STORE_REGISTRY = Concurrent::Map.new
  INCR_WITH_INITIAL_EXPIRE = <<~LUA
    local value = redis.call("INCRBY", KEYS[1], ARGV[1])
    if value == tonumber(ARGV[1]) then
      redis.call("EXPIRE", KEYS[1], ARGV[2])
    end
    return value
  LUA

  class << self
    def store
      STORE_REGISTRY.fetch_or_store(:default) { build_store }
    end

    def fail_mode
      ENV.fetch("RATE_LIMIT_FAIL_MODE", "open").to_s.downcase
    end

    def fail_close?
      fail_mode == "close"
    end

    def build_store
      url = ENV["RATE_LIMIT_REDIS_URL"].presence ||
        ENV["REDIS_URL"].presence ||
        ENV["VALKEY_RAILS_RATE_LIMIT_URL"].presence ||
        ENV["VALKEY_RACK_ATTACK_URL"].presence
      namespace = ENV["RATE_LIMIT_NAMESPACE"].presence || default_namespace

      return NullStore.new(fail_mode: fail_mode) if url.blank?

      RedisStore.new(url: url, namespace: namespace)
    rescue StandardError => e
      Rails.logger.error("[RailsRateLimit] store init failed: #{e.class}: #{e.message}")
      NullStore.new(fail_mode: fail_mode)
    end
  end

  def self.default_namespace
    return DEFAULT_NAMESPACE unless Rails.env.test?

    "rate_limit:test:#{Process.pid}"
  end

  class RedisStore
    attr_reader :namespace

    def initialize(url:, namespace:)
      @namespace = namespace
      @redis = Redis.new(url: url)
      @redis.ping
    end

    def increment(key, amount = 1, expires_in:)
      amount_int = amount.to_i
      ttl = expires_in.to_i
      ttl = 1 if ttl <= 0

      @redis.eval(
        INCR_WITH_INITIAL_EXPIRE,
        keys: [namespaced(key)],
        argv: [amount_int, ttl],
      ).to_i
    end

    def clear!
      cursor = "0"
      pattern = "#{@namespace}:*"

      loop do
        cursor, keys = @redis.scan(cursor, match: pattern, count: 1000)
        @redis.del(*keys) if keys.present?
        break if cursor == "0"
      end
    end

    def flushdb!
      @redis.flushdb
    end

    private

    def namespaced(key)
      "#{@namespace}:#{key}"
    end
  end

  class NullStore
    def initialize(fail_mode:)
      @fail_mode = fail_mode.to_s
    end

    def increment(*)
      raise StandardError, "Rate limit store unavailable" if @fail_mode == "close"

      0
    end

    def clear!
      nil
    end
  end
end
