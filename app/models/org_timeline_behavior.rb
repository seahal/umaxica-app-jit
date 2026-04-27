# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime
#  subject_type :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  actor_id     :bigint
#  event_id     :bigint           not null
#  level_id     :bigint           not null
#  subject_id   :bigint           not null
#
# Indexes
#
#  index_org_timeline_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_org_timeline_behaviors_on_event_id                     (event_id)
#  index_org_timeline_behaviors_on_level_id                     (level_id)
#  index_org_timeline_behaviors_on_subject_id                   (subject_id)
#  index_org_timeline_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => org_timeline_behavior_events.id)
#  fk_rails_...  (level_id => org_timeline_behavior_levels.id)
#

class OrgTimelineBehavior < BehaviorRecord
  include Behavior

  # Virtual belongs_to for ERD - uses subject_id/subject_type instead of FK
  belongs_to :org_timeline, optional: true, foreign_key: :subject_id, inverse_of: :org_timeline_behaviors
  belongs_to :org_timeline_behavior_level, foreign_key: :level_id, inverse_of: :org_timeline_behaviors
  belongs_to :org_timeline_behavior_event,
             class_name: "OrgTimelineBehaviorEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_timeline_behaviors

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  def org_timeline
    subject if subject_type == "OrgTimeline"
  end

  def org_timeline=(timeline)
    self.subject = timeline
  end
end
