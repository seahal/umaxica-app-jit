# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
#  id :string(255)      default("NEYO"), not null, primary key

class OrgTimelineAuditLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1
  DEBUG = 2
  INFO = 3
  WARN = 4
  ERROR = 5

  has_many :org_timeline_audits, dependent: :restrict_with_error, inverse_of: :org_timeline_audit_level
end
