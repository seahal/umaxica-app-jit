# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_levels
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_audit_levels_on_code  (code) UNIQUE
#
class ComPreferenceAuditLevel < AuditRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :com_preference_audits, dependent: :restrict_with_error, inverse_of: :com_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }
end
