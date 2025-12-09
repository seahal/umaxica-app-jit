class AppTimelineAudit < BusinessesRecord
  self.table_name = "app_timeline_audits"

  belongs_to :app_timeline
  # event_id references AppTimelineAuditEvent.id (string)
  belongs_to :app_timeline_audit_event,
             class_name: "AppTimelineAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_timeline_audits
end
