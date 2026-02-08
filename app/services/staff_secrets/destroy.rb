# frozen_string_literal: true

module StaffSecrets
  class Destroy
    ACTION = "staff_secret.delete"
    EVENT_ID = StaffAuditEvent::STAFF_SECRET_REMOVED

    def self.call(actor:, secret:)
      new(actor: actor, secret: secret).call
    end

    def initialize(actor:, secret:)
      @actor = actor
      @secret = secret
    end

    def call
      StaffAudit.transaction do
        StaffSecret.transaction do
          ensure_audit_dependencies!
          StaffAudit.create!(
            actor: @actor,
            subject_type: "StaffSecret",
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

    def ensure_audit_dependencies!
      ActivityRecord.connected_to(role: :writing) do
        StaffAuditEvent.find_or_create_by!(id: EVENT_ID)
        StaffAuditLevel.find_or_create_by!(id: StaffAuditLevel::NEYO)
      end
    end
  end
end
