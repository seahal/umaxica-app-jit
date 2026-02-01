# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_org_timeline_audit_levels_on_id  (id) UNIQUE
#
#  id :string(255)      default("NEYO"), not null, primary key

class OrgTimelineAuditLevel < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :org_timeline_audits, dependent: :restrict_with_error, inverse_of: :org_timeline_audit_level
end
