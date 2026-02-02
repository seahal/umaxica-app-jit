# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_timeline_audit_events_on_code  (code) UNIQUE
#

class OrgTimelineAuditEvent < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :org_timeline_audits,
           class_name: "OrgTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_timeline_audit_event,
           dependent: :restrict_with_error
end
