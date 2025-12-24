# == Schema Information
#
# Table name: user_identity_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  ip_address     :string           default(""), not null
#  level_id       :string(255)      default("NONE"), not null
#  previous_value :text             default(""), not null
#  timestamp      :datetime         default("-infinity"), not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_user_identity_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_user_identity_audits_on_event_id                 (event_id)
#  index_user_identity_audits_on_level_id                 (level_id)
#  index_user_identity_audits_on_user_id                  (user_id)
#

class UserIdentityAudit < IdentitiesRecord
  belongs_to :user, inverse_of: :user_identity_audits
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :user_identity_audit_event, foreign_key: :event_id, inverse_of: :user_identity_audits
  belongs_to :user_identity_audit_level, foreign_key: :level_id, inverse_of: :user_identity_audits

  before_validation do
    if actor_id.blank?
      self.actor_id = "00000000-0000-0000-0000-000000000000"
      self.actor_type ||= "User"
    end
  end

  encrypts :previous_value
end
