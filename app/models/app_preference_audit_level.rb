# typed: false
# == Schema Information
#
# Table name: app_preference_audit_levels
# Database name: audit
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class AppPreferenceAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :app_preference_audits, dependent: :restrict_with_error, inverse_of: :app_preference_audit_level
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true,
            if: -> { self.class.column_names.include?("position") }
end
