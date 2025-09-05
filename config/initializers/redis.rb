# frozen_string_literal: true

# Redis configuration for the application
default_redis_url =
  if ENV["REDIS_DEFAULT_URL"].present?
    ENV["REDIS_DEFAULT_URL"]
  elsif File.exist?("/.dockerenv")
    Rails.application.credentials.dig(:REDIS, :REDIS_NORMAL_URL)
  end

# Configure SSL for production Redis (Upstash requires SSL)
redis_config = { url: default_redis_url }

if Rails.env.production?
  redis_config[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

REDIS_CLIENT = Redis.new(redis_config)

# Connection smoke test (skip in test)
unless Rails.env.test?
  begin
    REDIS_CLIENT.ping
    Rails.logger.info "✅ Redis connected successfully"
  rescue StandardError => e
    Rails.logger.error "❌ Redis connection failed: #{e.class}: #{e.message} (url=#{default_redis_url})"
    # Fail fast only in development to surface local setup issues
    raise e if Rails.env.development?
  end
end
