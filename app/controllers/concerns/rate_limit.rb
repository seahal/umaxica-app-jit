# typed: false
# frozen_string_literal: true

# Rate limiting concern backed by Rails 8.1's built-in `rate_limit` DSL.
#
# Uses a dedicated RedisCacheStore (Valkey) for atomic counter operations.
# Include this concern in any controller to get default rate limits:
#   - Web requests: 300 req/min by IP
#   - API requests: 600 req/min by IP
#
# Controllers can declare additional limits via the standard Rails DSL:
#   rate_limit to: 5, within: 1.minute, store: rate_limit_store, only: :create, name: "login"
module RateLimit
  extend ActiveSupport::Concern

  # Lazy-initialised per-process store.
  # In test mode each forked parallel worker gets its own MemoryStore
  # so that concurrent workers do not interfere with each other's counters.
  STORE_REGISTRY = {} # rubocop:disable ThreadSafety/MutableClassInstanceVariable
  private_constant :STORE_REGISTRY

  def self.store
    STORE_REGISTRY[Process.pid] ||= build_store
  end

  def self.build_store
    if Rails.env.test?
      ActiveSupport::Cache::MemoryStore.new
    else
      url = ENV.fetch("RATE_LIMIT_REDIS_URL", "redis://localhost:6379/0")
      ActiveSupport::Cache::RedisCacheStore.new(url: url, namespace: "rate_limit")
    end
  rescue StandardError => e
    Rails.logger&.error("[RateLimit] store init failed: #{e.class}: #{e.message}")
    ActiveSupport::Cache::MemoryStore.new
  end

  DEFAULT_RETRY_AFTER = 60

  included do
    rate_limit to: 300, within: 1.minute,
               by: -> { request.remote_ip },
               with: -> { handle_rate_limit_exceeded!("default_web", DEFAULT_RETRY_AFTER) },
               store: RateLimit.store,
               name: "default_web",
               if: -> { !request.format.json? && !Rails.env.test? }

    rate_limit to: 600, within: 1.minute,
               by: -> { request.remote_ip },
               with: -> { handle_rate_limit_exceeded!("default_api", DEFAULT_RETRY_AFTER) },
               store: RateLimit.store,
               name: "default_api",
               if: -> { request.format.json? && !Rails.env.test? }
  end

  class_methods do
    def rate_limit_store
      RateLimit.store
    end
  end

  private

  def handle_rate_limit_exceeded!(rule_name, retry_after = DEFAULT_RETRY_AFTER)
    retry_after_seconds = retry_after.to_i.positive? ? retry_after.to_i : DEFAULT_RETRY_AFTER
    message = I18n.t("errors.rate_limit.exceeded")

    response.headers["X-RateLimit-Layer"] = "rails"
    response.headers["X-RateLimit-Rule"] = rule_name.to_s
    response.headers["Retry-After"] = retry_after_seconds.to_s

    if request.format.json?
      render json: { error: "rate_limited", rule: rule_name.to_s, message: message },
             status: :too_many_requests
    else
      render plain: message, status: :too_many_requests
    end
  end
end
