# == Schema Information
#
# Table name: staff_identity_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  ip_address     :string           default(""), not null
#  level_id       :string           default("NONE"), not null
#  previous_value :text             default(""), not null
#  staff_id       :uuid             not null
#  timestamp      :datetime         default("-infinity"), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_staff_identity_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_staff_identity_audits_on_event_id                 (event_id)
#  index_staff_identity_audits_on_level_id                 (level_id)
#  index_staff_identity_audits_on_staff_id                 (staff_id)
#

class StaffIdentityAudit < IdentitiesRecord
  belongs_to :staff, inverse_of: :staff_identity_audits
  belongs_to :staff_identity_audit_event, foreign_key: :event_id, inverse_of: :staff_identity_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :staff_identity_audit_level, foreign_key: :level_id, inverse_of: :staff_identity_audits
  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  encrypts :previous_value
end
