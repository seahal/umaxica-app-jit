# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NEYO"), not null
#  ip_address     :string           default(""), not null
#  level_id       :string           default("NEYO"), not null
#  previous_value :text
#  staff_id       :uuid             not null
#  subject_id     :string
#  subject_type   :string           default(""), not null
#  timestamp      :datetime         not null
#  updated_at     :datetime         not null
#  context        :jsonb            default("{}"), not null
#
# Indexes
#
#  index_staff_identity_audits_on_event_id    (event_id)
#  index_staff_identity_audits_on_level_id    (level_id)
#  index_staff_identity_audits_on_staff_id    (staff_id)
#  index_staff_identity_audits_on_subject_id  (subject_id)
#

class StaffAudit < OperatorRecord
  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  attribute :level_id, default: "NEYO"

  # Helper methods for compatibility with existing code
  before_create :set_timestamp

  def set_timestamp
    self.timestamp ||= Time.current
  end

  def staff
    Staff.find(subject_id) if subject_type == "Staff"
  end

  def staff=(staff)
    self.subject_id = staff.id.to_s
    self.subject_type = "Staff"
    self.staff_id = staff.id
  end

  # Alias for backward compatibility
  alias_attribute :occurred_at, :timestamp

  belongs_to :staff_audit_event, foreign_key: :event_id, inverse_of: :staff_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_audit_level, foreign_key: :level_id, inverse_of: :staff_audits
  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  # Validate that event_id exists in staff_audit_events table
  validate :event_id_must_exist

  def event_id_must_exist
    return if event_id.blank?
    return if StaffAuditEvent.exists?(id: event_id)

    errors.add(:event_id, "must reference a valid staff audit event")
  end

  encrypts :previous_value
end
