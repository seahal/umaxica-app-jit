class OrgTimelineAudit < BusinessesRecord
  self.table_name = "org_timeline_audits"

  belongs_to :org_timeline
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :org_timeline_audit_level, foreign_key: :level_id, inverse_of: :org_timeline_audits
  belongs_to :org_timeline_audit_event,
             class_name: "OrgTimelineAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_timeline_audits
end
