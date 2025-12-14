# frozen_string_literal: true

class AppTimelineAuditEvent < BusinessesRecord
  include UppercaseIdValidation

  self.table_name = "app_timeline_audit_events"

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :app_timeline_audits,
           class_name: "AppTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :app_timeline_audit_event,
           dependent: :restrict_with_exception
end
