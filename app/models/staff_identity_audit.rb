# == Schema Information
#
# Table name: staff_identity_audits
#
#  id             :uuid             not null, primary key
#  subject_id     :string           not null
#  subject_type   :text             not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :text             default(""), not null
#  event_id       :string(255)      default("NONE"), not null
#  level_id       :string(255)      default("NONE"), not null
#  occurred_at    :datetime         not null
#  expires_at     :datetime         not null
#  ip_address     :inet             default("0.0.0.0"), not null
#  context        :jsonb            default("{}"), not null
#  previous_value :text             default(""), not null
#  current_value  :text             default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_2e96c29236    (subject_type,subject_id,occurred_at)
#  index_staff_identity_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_staff_identity_audits_on_event_id                  (event_id)
#  index_staff_identity_audits_on_expires_at                (expires_at)
#  index_staff_identity_audits_on_level_id                  (level_id)
#  index_staff_identity_audits_on_occurred_at               (occurred_at)
#

class StaffIdentityAudit < IdentitiesRecord
  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  # Helper methods for compatibility with existing code
  def staff
    Staff.find(subject_id) if subject_type == "Staff"
  end

  def staff=(staff)
    self.subject_id = staff.id.to_s
    self.subject_type = "Staff"
  end

  def staff_id
    subject_id if subject_type == "Staff"
  end

  def staff_id=(id)
    self.subject_id = id.to_s
    self.subject_type = "Staff"
  end

  # Alias for backward compatibility
  alias_attribute :timestamp, :occurred_at

  belongs_to :staff_identity_audit_event, foreign_key: :event_id, inverse_of: :staff_identity_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_identity_audit_level, foreign_key: :level_id, inverse_of: :staff_identity_audits
  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  encrypts :previous_value
end
