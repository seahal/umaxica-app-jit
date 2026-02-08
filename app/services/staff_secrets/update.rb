# frozen_string_literal: true

module StaffSecrets
  class Update
    ACTION = "staff_secret.update"
    EVENT_ID = StaffAuditEvent::STAFF_SECRET_UPDATED

    Result = Struct.new(:secret, keyword_init: true)

    def self.call(actor:, secret:, params:)
      new(actor: actor, secret: secret, params: params).call
    end

    def initialize(actor:, secret:, params:)
      @actor = actor
      @secret = secret
      @params = params
    end

    def call
      @secret.name = @params[:name].to_s.strip if @params[:name].present?
      @secret.staff_secret_status_id = status_id_for(@params[:enabled]) if @params.key?(:enabled)

      StaffAudit.transaction do
        StaffSecret.transaction do
          ensure_audit_dependencies!
          @secret.save!
          StaffAudit.create!(
            actor: @actor,
            subject_type: "StaffSecret",
            subject_id: @secret.id.to_s,
            event_id: EVENT_ID,
            occurred_at: Time.current,
            context: { action: ACTION },
          )
        end
      end

      Result.new(secret: @secret)
    end

    private

    def status_id_for(enabled_param)
      enabled = ActiveModel::Type::Boolean.new.cast(enabled_param)
      status = enabled ? :active : :revoked
      StaffSecret.status_id_for(status)
    end

    def ensure_audit_dependencies!
      ActivityRecord.connected_to(role: :writing) do
        StaffAuditEvent.find_or_create_by!(id: EVENT_ID)
        StaffAuditLevel.find_or_create_by!(id: StaffAuditLevel::NEYO)
      end
    end
  end
end
