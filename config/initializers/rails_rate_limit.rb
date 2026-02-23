# typed: false
# frozen_string_literal: true

module RailsRateLimit
  STORE_NAMESPACE = "rails_rate_limit"

  class << self
    attr_accessor :store
  end
end

RailsRateLimit.store =
  if Rails.env.test?
    ActiveSupport::Cache::MemoryStore.new(namespace: RailsRateLimit::STORE_NAMESPACE)
  else
    ActiveSupport::Cache::RedisCacheStore.new(
      url: ENV.fetch("VALKEY_RAILS_RATE_LIMIT_URL", ENV.fetch("VALKEY_RACK_ATTACK_URL")),
      namespace: RailsRateLimit::STORE_NAMESPACE,
      reconnect_attempts: 3,
      timeout: 1.0,
    )
  end
