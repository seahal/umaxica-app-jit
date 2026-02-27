# typed: false
# frozen_string_literal: true

module Sign
  module Risk
    class Emitter
      def self.emit(name, **payload)
        return unless feature_enabled?

        event = Event.new(name, payload: payload)
        persist(event)
      end

      def self.persist(event)
        # Use Redis if available
        return unless defined?(REDIS_CLIENT)

        user_id = event.payload[:user_id]
        # Fallback for events that might use different keys, but minimal scope requires user_id
        return unless user_id

        key = "sign:risk:events:#{user_id}"
        score = event.occurred_at.to_f
        member = event.to_h.to_json

        # Use sorted set to keep timeline
        REDIS_CLIENT.zadd(key, score, member)
        # Expire entire set after 1 hour (sliding window container)
        REDIS_CLIENT.expire(key, 1.hour)
      end

      def self.feature_enabled?
        # Check Rails config first, then ENV
        # Using .try to avoid error if x is not defined or risk_enforcement undefined
        enabled_config = Rails.configuration.try(:x).try(:risk_enforcement).try(:enabled)
        enabled_config || ENV["RISK_ENFORCEMENT_ENABLED"] == "true"
      end
    end
  end
end
