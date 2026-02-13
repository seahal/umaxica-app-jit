# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behaviors
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
#  idx_on_subject_type_subject_id_occurred_at_cbca2c0dea     (subject_type,subject_id,occurred_at)
#  index_com_timeline_behaviors_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_com_timeline_behaviors_on_event_id                  (event_id)
#  index_com_timeline_behaviors_on_expires_at                (expires_at)
#  index_com_timeline_behaviors_on_level_id                  (level_id)
#  index_com_timeline_behaviors_on_occurred_at               (occurred_at)
#  index_com_timeline_behaviors_on_subject_id                (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => com_timeline_behavior_events.id)
#  fk_rails_...  (level_id => com_timeline_behavior_levels.id)
#

class ComTimelineBehavior < ActivityRecord
  # Virtual belongs_to for ERD - uses subject_id/subject_type instead of FK
  belongs_to :com_timeline, optional: true, foreign_key: :subject_id, inverse_of: :com_timeline_behaviors
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :com_timeline_behavior_level, foreign_key: :level_id, inverse_of: :com_timeline_behaviors
  belongs_to :com_timeline_behavior_event,
             class_name: "ComTimelineBehaviorEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :com_timeline_behaviors
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  def com_timeline
    ComTimeline.find(subject_id) if subject_type == "ComTimeline"
  end

  def com_timeline=(timeline)
    self.subject_id = timeline.id.to_s
    self.subject_type = "ComTimeline"
  end
end
