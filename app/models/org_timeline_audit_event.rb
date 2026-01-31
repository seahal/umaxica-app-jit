# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_org_timeline_audit_events_on_id  (id) UNIQUE
#

class OrgTimelineAuditEvent < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :org_timeline_audits,
           class_name: "OrgTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_timeline_audit_event,
           dependent: :restrict_with_error
end
