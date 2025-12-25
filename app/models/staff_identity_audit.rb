# == Schema Information
#
# Table name: staff_identity_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default(""), not null
#  ip_address     :string           default(""), not null
#  level_id       :string           default("NONE"), not null
#  subject_id     :string
#  subject_type   :string           default(""), not null
#  previous_value :text
#  staff_id       :uuid             not null
#  timestamp      :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_staff_identity_audits_on_event_id    (event_id)
#  index_staff_identity_audits_on_level_id    (level_id)
#  index_staff_identity_audits_on_staff_id    (staff_id)
#  index_staff_identity_audits_on_subject_id  (subject_id)
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
    self.staff_id = staff.id
  end

  def staff_id=(id)
    self.subject_id = id.to_s
    self.subject_type = "Staff"
    write_attribute(:staff_id, id)
  end

  # Alias for backward compatibility
  alias_attribute :occurred_at, :timestamp

  belongs_to :staff_identity_audit_event, foreign_key: :event_id, inverse_of: :staff_identity_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_identity_audit_level, foreign_key: :level_id, inverse_of: :staff_identity_audits
  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  encrypts :previous_value
end
