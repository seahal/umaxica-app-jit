# == Schema Information
#
# Table name: user_identity_audits
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
#  timestamp      :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_user_identity_audits_on_event_id    (event_id)
#  index_user_identity_audits_on_level_id    (level_id)
#  index_user_identity_audits_on_subject_id  (subject_id)
#  index_user_identity_audits_on_user_id     (user_id)
#

class UserIdentityAudit < IdentitiesRecord
  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  # Helper methods for compatibility with existing code
  def user
    User.find(subject_id) if subject_type == "User"
  end

  before_create :set_timestamp

  def set_timestamp
    self.timestamp ||= Time.current
  end

  def user=(user)
    self.subject_id = user.id.to_s
    self.subject_type = "User"
    self.user_id = user.id
  end

  def user_id=(id)
    self.subject_id = id.to_s
    self.subject_type = "User"
    write_attribute(:user_id, id)
  end

  # Alias for backward compatibility
  alias_attribute :occurred_at, :timestamp

  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :user_identity_audit_event, foreign_key: :event_id, inverse_of: :user_identity_audits
  belongs_to :user_identity_audit_level, foreign_key: :level_id, inverse_of: :user_identity_audits
  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  before_validation do
    if actor_id.blank?
      self.actor_id = "00000000-0000-0000-0000-000000000000"
      self.actor_type ||= "User"
    end
  end

  encrypts :previous_value
end
