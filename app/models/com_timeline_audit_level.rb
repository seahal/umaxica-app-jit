# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#

class ComTimelineAuditLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :com_timeline_audits, dependent: :restrict_with_error, inverse_of: :com_timeline_audit_level
end
