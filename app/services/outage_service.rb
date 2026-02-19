# frozen_string_literal: true

class OutageService
  class OutageError < StandardError; end

  OUTAGE_STATES = %w(maintenance degraded operational).freeze
  CACHE_PREFIX = "outage_state"
  DEFAULT_TTL = 1.hour

  ALLOWED_ROUTES_DURING_OUTAGE = %w(
    /up
    /health
    /edge/v1/health
  ).freeze

  class << self
    def update!(surface:, state:, actor_id:, reason:, duration: nil)
      raise OutageError, "Invalid state: #{state}" unless OUTAGE_STATES.include?(state)

      cache_key = outage_cache_key(surface)
      ttl = duration || DEFAULT_TTL
      expires_at = ttl.seconds.from_now

      outage_data = {
        surface: surface,
        state: state,
        actor_id: actor_id,
        reason: reason,
        started_at: Time.current,
        expires_at: expires_at,
      }

      Rails.cache.write(cache_key, outage_data, expires_in: ttl.seconds)

      record_audit(surface, outage_data)

      outage_data
    end

    def current(surface)
      cache_key = outage_cache_key(surface)
      Rails.cache.read(cache_key)
    end

    def state(surface)
      outage = current(surface)
      outage&.dig(:state) || "operational"
    end

    def active?(surface)
      state(surface) != "operational"
    end

    def maintenance?(surface)
      state(surface) == "maintenance"
    end

    def degraded?(surface)
      state(surface) == "degraded"
    end

    def operational?(surface)
      state(surface) == "operational"
    end

    def allowed_during_outage?(path)
      return true if ALLOWED_ROUTES_DURING_OUTAGE.any? { |route| path.start_with?(route) }

      false
    end

    def clear!(surface, actor_id:, reason:)
      cache_key = outage_cache_key(surface)
      previous = Rails.cache.read(cache_key)
      Rails.cache.delete(cache_key)

      record_audit(
        surface,
        {
          state: "operational",
          actor_id: actor_id,
          reason: reason,
          previous_state: previous&.dig(:state),
          cleared_at: Time.current,
        },
      )

      true
    end

    private

    def outage_cache_key(surface)
      "#{CACHE_PREFIX}:#{surface}"
    end

    def record_audit(surface, data)
      Rails.event.notify(
        "outage.state_changed",
        surface: surface,
        state: data[:state],
        actor_id: data[:actor_id],
        reason: data[:reason],
      )
    rescue StandardError => e
      Rails.logger.error("[OutageService] Failed to record audit: #{e.message}")
      Rails.error.report(e, handled: true, severity: :warning)
    end
  end
end
