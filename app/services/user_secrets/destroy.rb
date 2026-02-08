# frozen_string_literal: true

module UserSecrets
  class Destroy
    ACTION = "user_secret.delete"
    EVENT_ID = UserAuditEvent::USER_SECRET_REMOVED

    def self.call(actor:, secret:)
      new(actor: actor, secret: secret).call
    end

    def initialize(actor:, secret:)
      @actor = actor
      @secret = secret
    end

    def call
      audit_class.transaction do
        UserSecret.transaction do
          ensure_audit_dependencies!
          audit_class.create!(
            actor: @actor,
            subject_type: "UserSecret",
            subject_id: @secret.id.to_s,
            event_id: EVENT_ID,
            occurred_at: Time.current,
            context: { action: ACTION },
          )
          @secret.destroy!
        end
      end
    end

    private

    def audit_class
      @audit_class ||= @actor.is_a?(Staff) ? StaffAudit : UserAudit
    end

    def ensure_audit_dependencies!
      ActivityRecord.connected_to(role: :writing) do
        UserAuditEvent.find_or_create_by!(id: EVENT_ID)
        UserAuditLevel.find_or_create_by!(id: UserAuditLevel::NEYO)
      end
    end
  end
end
