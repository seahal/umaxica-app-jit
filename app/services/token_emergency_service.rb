# frozen_string_literal: true

class TokenEmergencyService
  class EmergencyActionError < StandardError; end

  EMERGENCY_ACTIONS = %w(access_reset refresh_freeze refresh_unfreeze revoke_all).freeze
  REFRESH_UNFREEZE_EXPIRY = 30.days
  TOKEN_FOREIGN_KEYS = { "UserToken" => :user_id, "StaffToken" => :staff_id }.freeze

  def self.call!(action:, surface:, actor_id:, reason:)
    raise EmergencyActionError, "Invalid action: #{action}" unless EMERGENCY_ACTIONS.include?(action)

    token_class = token_class_for_surface(surface)
    raise EmergencyActionError, "Invalid surface: #{surface}" unless token_class

    result = perform_action(action, token_class, actor_id)
    record_audit(action, surface, actor_id, reason, result)

    result
  end

  def self.perform_action(action, token_class, actor_id)
    case action
    when "access_reset"
      perform_access_reset(token_class, actor_id)
    when "refresh_freeze"
      perform_refresh_freeze(token_class, actor_id)
    when "refresh_unfreeze"
      perform_refresh_unfreeze(token_class, actor_id)
    when "revoke_all"
      perform_revoke_all(token_class, actor_id)
    else
      raise EmergencyActionError, "Unknown action: #{action}"
    end
  end

  def self.token_class_for_surface(surface)
    case surface.to_s
    when "app", "com", "org"
      UserToken
    when "staff"
      StaffToken
    else
      nil
    end
  end

  def self.perform_access_reset(token_class, actor_id)
    TokenRecord.connected_to(role: :writing) do
      token_class.transaction do
        scope = token_class.where(resource_foreign_key(token_class) => actor_id, :revoked_at => nil)
        # rubocop:disable Rails/SkipsModelValidations
        affected = scope.update_all(revoked_at: Time.current, updated_at: Time.current)
        # rubocop:enable Rails/SkipsModelValidations
        { affected_count: affected, action: "access_reset" }
      end
    end
  end

  def self.perform_refresh_freeze(token_class, actor_id)
    TokenRecord.connected_to(role: :writing) do
      token_class.transaction do
        scope = token_class.where(resource_foreign_key(token_class) => actor_id, :revoked_at => nil)
        now = Time.current
        # rubocop:disable Rails/SkipsModelValidations
        affected = scope.update_all(refresh_expires_at: now, updated_at: now)
        # rubocop:enable Rails/SkipsModelValidations
        { affected_count: affected, action: "refresh_freeze" }
      end
    end
  end

  def self.perform_refresh_unfreeze(token_class, actor_id)
    TokenRecord.connected_to(role: :writing) do
      token_class.transaction do
        scope = token_class.where(resource_foreign_key(token_class) => actor_id, :revoked_at => nil)
        new_expiry = REFRESH_UNFREEZE_EXPIRY.from_now
        # rubocop:disable Rails/SkipsModelValidations
        affected = scope.update_all(refresh_expires_at: new_expiry, updated_at: Time.current)
        # rubocop:enable Rails/SkipsModelValidations
        { affected_count: affected, action: "refresh_unfreeze", new_expiry: new_expiry }
      end
    end
  end

  def self.perform_revoke_all(token_class, actor_id)
    # Intentionally targets ALL tokens (including already-revoked) to ensure
    # status field is updated and consistent. Use access_reset to target only active tokens.
    TokenRecord.connected_to(role: :writing) do
      token_class.transaction do
        scope = token_class.where(resource_foreign_key(token_class) => actor_id)
        # rubocop:disable Rails/SkipsModelValidations
        affected = scope.update_all(revoked_at: Time.current, status: "revoked", updated_at: Time.current)
        # rubocop:enable Rails/SkipsModelValidations
        { affected_count: affected, action: "revoke_all" }
      end
    end
  end

  def self.resource_foreign_key(token_class)
    TOKEN_FOREIGN_KEYS.fetch(token_class.name) do
      raise EmergencyActionError, "Unknown token class: #{token_class} — add to TOKEN_FOREIGN_KEYS"
    end
  end

  def self.record_audit(action, surface, actor_id, reason, result)
    Rails.event.notify(
      "token.emergency_action",
      action: action,
      surface: surface,
      actor_id: actor_id,
      reason: reason,
      affected_count: result[:affected_count],
    )
  rescue StandardError => e
    Rails.logger.error("[TokenEmergencyService] Failed to record audit: #{e.message}")
    Rails.error.report(e, handled: true, severity: :warning)
  end

  private_class_method :perform_action, :token_class_for_surface,
                       :perform_access_reset, :perform_refresh_freeze,
                       :perform_refresh_unfreeze, :perform_revoke_all,
                       :resource_foreign_key, :record_audit
end
