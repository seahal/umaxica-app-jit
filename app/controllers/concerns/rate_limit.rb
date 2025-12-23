module RateLimit
  extend ActiveSupport::Concern

  RATE_LIMIT_STORE = ActiveSupport::Cache::RedisCacheStore.new(
    url: Rails.application.credentials.dig(:REDIS, :REDIS_RACK_ATTACK_URL)
  )

  included do
    rate_limit to: 1000, within: 1.hour, store: RATE_LIMIT_STORE unless Rails.env.test?
  end
end
