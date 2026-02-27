# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_activities
# Database name: activity
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
#  actor_id       :bigint           default(0), not null
#  event_id       :bigint           default(0), not null
#  level_id       :bigint           default(4), not null
#  subject_id     :bigint           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_a29eb711dd  (subject_type,subject_id,occurred_at)
#  index_user_activities_on_actor                         (actor_type,actor_id)
#  index_user_activities_on_actor_id_and_occurred_at      (actor_id,occurred_at)
#  index_user_activities_on_event_id                      (event_id)
#  index_user_activities_on_expires_at                    (expires_at)
#  index_user_activities_on_level_id                      (level_id)
#  index_user_activities_on_occurred_at                   (occurred_at)
#  index_user_activities_on_subject_id                    (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => user_activity_events.id)
#  fk_rails_...  (level_id => user_activity_levels.id)
#

class UserActivity < ActivityRecord
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :user_activity_event, foreign_key: :event_id, inverse_of: :user_activities
  belongs_to :user_activity_level, foreign_key: :level_id, inverse_of: :user_activities
  # subject_id/subject_type for cross-DB compatibility (no FK)
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  attribute :level_id, default: UserActivityLevel::NOTHING
  attribute :subject_id, :string

  validates :event_id, numericality: { only_integer: true }, allow_nil: true
  validates :level_id, numericality: { only_integer: true }, allow_nil: true
  # Validate that event_id exists in user_activity_events table
  validate :event_id_must_exist
  before_create :set_timestamp
  before_validation do
    if actor_id.blank? && actor_type.blank?
      self.actor_id = 0
      self.actor_type = "User"
    end
  end
  # Helper methods for compatibility with existing code
  def user
    User.find(subject_id) if subject_type == "User"
  end

  def user_id
    subject_id if subject_type == "User"
  end

  def set_timestamp
    self.timestamp ||= Time.current
  end

  def user=(user)
    self.subject_id = user.id.to_s
    self.subject_type = "User"
  end

  # Alias for backward compatibility
  alias_attribute :timestamp, :occurred_at

  def event_id_must_exist
    return if event_id.blank?

    # Always use writing role to check event existence (avoid read replica lag)
    exists =
      ActivityRecord.connected_to(role: :writing) do
        UserActivityEvent.exists?(id: event_id)
      end

    return if exists

    errors.add(:event_id, "must reference a valid user audit event")
  end

  encrypts :previous_value
end
