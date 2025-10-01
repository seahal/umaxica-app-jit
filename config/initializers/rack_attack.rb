# Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: Rails.application.credentials.dig(:REDIS, :REDIS_RACK_ATTACK_URL))
