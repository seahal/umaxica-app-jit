# typed: false
# frozen_string_literal: true

module Sign
  module Risk
    class Enforcer
      # resource: The user/staff record (ActiveRecord)
      def self.call(resource)
        return unless feature_enabled?
        return unless resource

        score =
          if resource.respond_to?(:staff_tokens)
            Engine.score(staff_id: resource.id)
          else
            Engine.score(user_id: resource.id)
          end

        if score >= 100
          revoke!(resource)
        elsif score >= 60
          require_step_up!(resource)
        end
      end

      def self.revoke!(resource)
        revoke_token_set(resource.user_tokens) if resource.respond_to?(:user_tokens)
        revoke_token_set(resource.staff_tokens) if resource.respond_to?(:staff_tokens)
      end

      def self.revoke_token_set(tokens)
        expiry_column = tokens.klass.column_names.include?("expired_at") ? :expired_at : :revoked_at
        tokens.where(expiry_column => nil).find_each do |token|
          token.revoke!
        end
      end

      def self.require_step_up!(resource)
        # FIXME: Step-up authentication flag storage needs a persistent mechanism.
        #   Previously used Redis SET with 10-minute TTL. Options:
        #   (1) Store as an occurrence record with short deletable_at
        #   (2) Use session-based flag
        #   (3) Add a column to the token/resource table
        #   Currently a no-op until the step-up verification reader is implemented.
        Rails.event.info(
          "sign.risk.enforcer.step_up_required",
          resource_type: resource.class.name,
          resource_id: resource.id,
        )
      end

      def self.feature_enabled?
        return false if ENV["RISK_ENFORCEMENT_DISABLED"] == "true"

        enabled_config = Rails.configuration.try(:x).try(:risk_enforcement).try(:enabled)
        enabled_config || ENV["RISK_ENFORCEMENT_ENABLED"] == "true" || Rails.env.production?
      end

      private_class_method :revoke_token_set
    end
  end
end
