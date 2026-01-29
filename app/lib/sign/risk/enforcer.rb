# frozen_string_literal: true

module Sign
  module Risk
    class Enforcer
      # resource: The user/staff record (ActiveRecord)
      def self.call(resource)
        return unless feature_enabled?
        return unless resource

        score = Engine.score(resource.id)

        if score >= 100
          revoke!(resource)
        elsif score >= 60
          require_step_up!(resource)
        end
      end

      def self.revoke!(resource)
        # Revoke all active tokens for this resource
        # Assuming resource has association :user_tokens or :staff_tokens
        # Or we use UserToken/StaffToken directly.
        # Check resource class name to decide? Or use association

        now = Time.current

        revoke_token_set(resource.user_tokens, now) if resource.respond_to?(:user_tokens)
        revoke_token_set(resource.staff_tokens, now) if resource.respond_to?(:staff_tokens)

        # Also refresh families? update_all on tokens essentially kills the family if query is by user
      end

      def self.revoke_token_set(tokens, now)
        tokens.where(revoked_at: nil).find_each do |token|
          token.update!(revoked_at: now)
        end
      end

      def self.require_step_up!(resource)
        # Mark step-up required.
        # Implementation is no-op (flag only).
        # We can store this in Redis to be picked up by middleware if needed.
        return unless defined?(REDIS_CLIENT)

        REDIS_CLIENT.set("sign:risk:step_up:#{resource.id}", "1", ex: 10.minutes)
      end

      def self.feature_enabled?
        enabled_config = Rails.configuration.try(:x).try(:risk_enforcement).try(:enabled)
        enabled_config || ENV["RISK_ENFORCEMENT_ENABLED"] == "true"
      end
    end
  end
end
