# == Schema Information
#
# Table name: org_timeline_audit_events
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OrgTimelineAuditEvent < UniversalRecord
  include UppercaseId

  self.table_name = "org_timeline_audit_events"

  has_many :org_timeline_audits,
           class_name: "OrgTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_timeline_audit_event,
           dependent: :restrict_with_error
end
