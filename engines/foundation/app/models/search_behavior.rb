# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: search_behaviors
# Database name: behavior
#
#  id           :bigint           not null, primary key
#  actor_type   :string
#  expires_at   :datetime
#  occurred_at  :datetime         not null
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
#  index_search_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_search_behaviors_on_event_id                     (event_id)
#  index_search_behaviors_on_level_id                     (level_id)
#  index_search_behaviors_on_subject_id                   (subject_id)
#  index_search_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => search_behavior_events.id)
#  fk_rails_...  (level_id => search_behavior_levels.id)
#

class SearchBehavior < BehaviorRecord
  # Allowed subject types for polymorphic lookup
  # This allowlist replaces safe_constantize for type safety and editor compatibility.
  SUBJECT_TYPE_CLASSES = {
    "User" => User,
  }.freeze

  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :search_behavior_level, foreign_key: :level_id, inverse_of: :search_behaviors
  belongs_to :search_behavior_event,
             class_name: "SearchBehaviorEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :search_behaviors

  validates :subject_id, presence: true
  validates :subject_type, presence: true
  validates_reference_table :event_id, association: :search_behavior_event
  validates_reference_table :level_id, association: :search_behavior_level
  validates :event_id, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :level_id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Return the searchable subject if subject_type corresponds to a valid model.
  # Uses an explicit allowlist instead of safe_constantize for type safety.
  def searchable
    return nil if subject_type.blank?

    klass = SUBJECT_TYPE_CLASSES[subject_type]
    klass.find_by(id: subject_id) if klass.respond_to?(:find_by)
  end
end
