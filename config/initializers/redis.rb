# frozen_string_literal: true

# Redis configuration for the application
REDIS_CLIENT = Redis.new(
  url: ENV.fetch("REDIS_URL", File.exist?("/.dockerenv") ? ENV["REDIS_NORMAL_URL"]: "redis://localhost:6379/0"),
  driver: :hiredis
)

# Test Redis connection on startup
begin
  REDIS_CLIENT.ping
  Rails.logger.info "✅ Redis connected successfully"
rescue Redis::ConnectionError => e
  Rails.logger.error "❌ Redis connection failed: #{e.message}"
  # Don't raise in production to allow graceful degradation
  raise e unless Rails.env.production?
end
