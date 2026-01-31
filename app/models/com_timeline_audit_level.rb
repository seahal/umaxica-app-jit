# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class ComTimelineAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :com_timeline_audits, dependent: :restrict_with_error, inverse_of: :com_timeline_audit_level
end
