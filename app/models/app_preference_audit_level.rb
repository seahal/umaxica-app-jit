# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_app_preference_audit_levels_on_id  (id) UNIQUE
#
class AppPreferenceAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :app_preference_audits, dependent: :restrict_with_error, inverse_of: :app_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true,
            if: -> { self.class.column_names.include?("position") }
end
