# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#
class ComPreferenceAuditEvent < AuditRecord
  include StringPrimaryKey

  self.record_timestamps = false

  # Placeholder for audit event types; ids are string tokens (e.g., 'CREATED')
  has_many :com_preference_audits,
           class_name: "ComPreferenceAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_preference_audit_event,
           dependent: :restrict_with_error
  scope :ordered, -> { column_names.include?("position") ? order(:position, :id) : order(:id) }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true,
            if: -> { self.class.column_names.include?("position") }

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
  before_validation { self.id = id&.upcase }
end
