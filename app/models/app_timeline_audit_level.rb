# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_app_timeline_audit_levels_on_id  (id) UNIQUE
#

class AppTimelineAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :app_timeline_audits, dependent: :restrict_with_error, inverse_of: :app_timeline_audit_level
end
