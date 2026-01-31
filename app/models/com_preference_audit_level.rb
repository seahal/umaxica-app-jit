# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_levels
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#
class ComPreferenceAuditLevel < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :com_preference_audits, dependent: :restrict_with_error, inverse_of: :com_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true,
            if: -> { self.class.column_names.include?("position") }
end
