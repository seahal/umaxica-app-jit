# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

class OrgTimelineAuditEvent < AuditRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1
  CREATED = 2
  UPDATED = 3
  DELETED = 4

  has_many :org_timeline_audits,
           class_name: "OrgTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_timeline_audit_event,
           dependent: :restrict_with_error
end
