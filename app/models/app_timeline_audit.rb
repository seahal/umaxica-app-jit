class AppTimelineAudit < BusinessesRecord
  self.table_name = "app_timeline_audits"

  belongs_to :app_timeline
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :app_timeline_audit_level, foreign_key: :level_id, inverse_of: :app_timeline_audits
  belongs_to :app_timeline_audit_event,
             class_name: "AppTimelineAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_timeline_audits
end
