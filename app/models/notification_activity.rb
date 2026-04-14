# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_activities
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
#  level_id       :bigint           default(0), not null
#  subject_id     :bigint           not null
#
# Indexes
#
#  idx_on_subject_type_subject_id_occurred_at_notification_act  (subject_type,subject_id,occurred_at)
#  index_notification_activities_on_actor_id_and_occurred_at    (actor_id,occurred_at)
#  index_notification_activities_on_event_id                    (event_id)
#  index_notification_activities_on_expires_at                  (expires_at)
#  index_notification_activities_on_level_id                    (level_id)
#  index_notification_activities_on_occurred_at                 (occurred_at)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => notification_activity_events.id)
#  fk_rails_...  (level_id => notification_activity_levels.id)
#
class NotificationActivity < ActivityRecord
  belongs_to :notification_activity_event,
             class_name: "NotificationActivityEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :notification_activities
  belongs_to :notification_activity_level,
             foreign_key: :level_id,
             inverse_of: :notification_activities

  validates :subject_id, presence: true
  validates :subject_type, presence: true

  validates_reference_table :event_id, association: :notification_activity_event
  validates_reference_table :level_id, association: :notification_activity_level
  validates :event_id, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :level_id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
