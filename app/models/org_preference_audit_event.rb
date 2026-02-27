# typed: false
# == Schema Information
#
# Table name: org_preference_audit_events
# Database name: audit
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class OrgPreferenceAuditEvent < AuditRecord
  include StringPrimaryKey

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :org_preference_audits,
           class_name: "OrgPreferenceAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :org_preference_audit_event,
           dependent: :restrict_with_error
  scope :ordered, -> { column_names.include?("position") ? order(:position, primary_key) : order(primary_key) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true,
            if: -> { self.class.column_names.include?("position") }

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
