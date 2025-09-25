# frozen_string_literal: true

# Redis configuration for the application
default_redis_url = Rails.application.credentials.dig(:REDIS, :REDIS_NORMAL_URL)

# Configure SSL for production Redis (Upstash requires SSL)
redis_config = { url: default_redis_url }

REDIS_CLIENT = Redis.new(redis_config)

# Connection smoke test (skip in test)
unless Rails.env.test?
  begin
    REDIS_CLIENT.ping
  rescue StandardError => e
    Rails.logger.error "❌ Redis connection failed: #{e.class}: #{e.message} (url=#{default_redis_url})"
    # Fail fast only in development to surface local setup issues
    raise e if Rails.env.development?
  end
end
