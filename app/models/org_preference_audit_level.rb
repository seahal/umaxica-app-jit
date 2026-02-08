# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
class OrgPreferenceAuditLevel < ActivityRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  INFO = 1

  has_many :org_preference_audits, dependent: :restrict_with_error, inverse_of: :org_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }
end
