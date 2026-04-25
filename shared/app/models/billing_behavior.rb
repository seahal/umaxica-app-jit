# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: billing_behaviors
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
#  index_billing_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_billing_behaviors_on_event_id                     (event_id)
#  index_billing_behaviors_on_level_id                     (level_id)
#  index_billing_behaviors_on_subject_id                   (subject_id)
#  index_billing_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => billing_behavior_events.id)
#  fk_rails_...  (level_id => billing_behavior_levels.id)
#

class BillingBehavior < BehaviorRecord
  belongs_to :billing_record, optional: true, foreign_key: :subject_id, inverse_of: :billing_behaviors
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :billing_behavior_level, foreign_key: :level_id, inverse_of: :billing_behaviors
  belongs_to :billing_behavior_event,
             class_name: "BillingBehaviorEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :billing_behaviors

  validates :subject_id, presence: true
  validates :subject_type, presence: true
  validates_reference_table :event_id, association: :billing_behavior_event
  validates_reference_table :level_id, association: :billing_behavior_level
  validates :event_id, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :level_id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def billing_record
    Billing.find(subject_id) if subject_type == "Billing"
  end

  def billing_record=(record)
    self.subject_id = record.id.to_s
    self.subject_type = "Billing"
  end
end
