# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_preference_audit_levels_on_code  (code) UNIQUE
#
class OrgPreferenceAuditLevel < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :org_preference_audits, dependent: :restrict_with_error, inverse_of: :org_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }
end
