# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class OrgTimelineAuditEvent < AuditRecord
  include StringPrimaryKey

  has_many :org_timeline_audits,
           class_name: "OrgTimelineAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_timeline_audit_event,
           dependent: :restrict_with_error
end
