# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_audits
#
#  id             :uuid             not null, primary key
#  subject_id     :string           not null
#  subject_type   :text             not null
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :text             default(""), not null
#  event_id       :string(255)      default("NEYO"), not null
#  level_id       :string(255)      default("NEYO"), not null
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
#  idx_on_subject_type_subject_id_occurred_at_a29eb711dd   (subject_type,subject_id,occurred_at)
#  index_user_identity_audits_on_actor                     (actor_type,actor_id)
#  index_user_identity_audits_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_user_identity_audits_on_event_id                  (event_id)
#  index_user_identity_audits_on_expires_at                (expires_at)
#  index_user_identity_audits_on_level_id                  (level_id)
#  index_user_identity_audits_on_occurred_at               (occurred_at)
#  index_user_identity_audits_on_subject_id                (subject_id)
#

class UserIdentityAudit < UniversalRecord
  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  attribute :level_id, default: "NEYO"

  # Helper methods for compatibility with existing code
  def user
    User.find(subject_id) if subject_type == "User"
  end

  def user_id
    subject_id if subject_type == "User"
  end

  before_create :set_timestamp

  def set_timestamp
    self.timestamp ||= Time.current
  end

  def user=(user)
    self.subject_id = user.id.to_s
    self.subject_type = "User"
  end

  # Alias for backward compatibility
  alias_attribute :timestamp, :occurred_at

  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :user_identity_audit_event, foreign_key: :event_id, inverse_of: :user_identity_audits
  belongs_to :user_identity_audit_level, foreign_key: :level_id, inverse_of: :user_identity_audits
  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  # Validate that event_id exists in user_identity_audit_events table
  validate :event_id_must_exist

  def event_id_must_exist
    return if event_id.blank?
    return if UserIdentityAuditEvent.exists?(id: event_id)

    errors.add(:event_id, "must reference a valid user identity audit event")
  end

  before_validation do
    if actor_id.blank?
      self.actor_id = "00000000-0000-0000-0000-000000000000"
      self.actor_type ||= "User"
    end
  end

  encrypts :previous_value
end
