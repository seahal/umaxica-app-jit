# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audits
# Database name: audit
#
#  id             :bigint           not null, primary key
#  actor_type     :text             default(""), not null
#  context        :jsonb            not null
#  current_value  :text             default(""), not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default(#<IPAddr: IPv4:0.0.0.0/255.255.255.255>), not null
#  occurred_at    :datetime         not null
#  previous_value :text             default(""), not null
#  subject_type   :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  event_id       :bigint           default(0), not null
#  level_id       :bigint           default(0), not null
#  subject_id     :string           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_2e96c29236    (subject_type,subject_id,occurred_at)
#  index_staff_audits_on_event_id                           (event_id)
#  index_staff_audits_on_level_id                           (level_id)
#  index_staff_identity_audits_on_actor                     (actor_type,actor_id)
#  index_staff_identity_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_staff_identity_audits_on_expires_at                (expires_at)
#  index_staff_identity_audits_on_occurred_at               (occurred_at)
#  index_staff_identity_audits_on_subject_id                (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => staff_audit_events.id)
#  fk_rails_...  (level_id => staff_audit_levels.id)
#

class StaffAudit < AuditRecord
  belongs_to :staff_audit_event, foreign_key: :event_id, inverse_of: :staff_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_audit_level, foreign_key: :level_id, inverse_of: :staff_audits
  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  attribute :level_id, default: "NEYO"

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }
  # Validate that event_id exists in staff_audit_events table
  validate :event_id_must_exist
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
  end

  # Alias for backward compatibility
  alias_attribute :timestamp, :occurred_at

  def event_id_must_exist
    return if event_id.blank?

    # Always use writing role to check event existence (avoid read replica lag)
    exists =
      AuditRecord.connected_to(role: :writing) do
        StaffAuditEvent.exists?(id: event_id)
      end

    return if exists

    errors.add(:event_id, "must reference a valid staff audit event")
  end

  encrypts :previous_value
end
