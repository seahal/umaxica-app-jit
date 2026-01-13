# == Schema Information
#
# Table name: org_preference_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class OrgPreferenceAuditLevel < AuditRecord
  include StringPrimaryKey

  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  has_many :org_preference_audits, dependent: :restrict_with_error, inverse_of: :org_preference_audit_level

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true,
            if: -> { self.class.column_names.include?("position") }
end
