class ComTimelineAudit < BusinessesRecord
  self.table_name = "com_timeline_audits"

  belongs_to :com_timeline
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :com_timeline_audit_event,
             class_name: "ComTimelineAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :com_timeline_audits
end
