class ComTimelineAuditEvent < BusinessesRecord
  self.table_name = "com_timeline_audit_events"

  has_many :com_timeline_audits,
           class_name: "ComTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_timeline_audit_event,
           dependent: :restrict_with_exception
end
