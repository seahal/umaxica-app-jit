# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class AppTimelineAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :app_timeline_audits, dependent: :restrict_with_error, inverse_of: :app_timeline_audit_level
end
