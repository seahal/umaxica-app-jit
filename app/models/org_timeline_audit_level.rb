# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#
#  id :string(255)      default("NEYO"), not null, primary key

class OrgTimelineAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :org_timeline_audits, dependent: :restrict_with_error, inverse_of: :org_timeline_audit_level
end
