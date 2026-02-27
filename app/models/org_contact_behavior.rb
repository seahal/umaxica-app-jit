# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_behaviors
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
#  index_org_contact_behaviors_on_actor_type_and_actor_id      (actor_type,actor_id)
#  index_org_contact_behaviors_on_event_id                     (event_id)
#  index_org_contact_behaviors_on_level_id                     (level_id)
#  index_org_contact_behaviors_on_subject_id                   (subject_id)
#  index_org_contact_behaviors_on_subject_type_and_subject_id  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => org_contact_behavior_events.id)
#  fk_rails_...  (level_id => org_contact_behavior_levels.id)
#
class OrgContactBehavior < BehaviorRecord
  belongs_to :org_contact, optional: true, foreign_key: :subject_id, inverse_of: :org_contact_behaviors
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :org_contact_behavior_level, foreign_key: :level_id, inverse_of: :org_contact_behaviors
  belongs_to :org_contact_behavior_event,
             class_name: "OrgContactBehaviorEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_contact_behaviors

  validates :subject_id, presence: true
  validates :subject_type, presence: true
  validates :event_id, numericality: { only_integer: true }, allow_nil: true
  validates :level_id, numericality: { only_integer: true }, allow_nil: true

  def org_contact
    OrgContact.find(subject_id) if subject_type == "OrgContact"
  end

  def org_contact=(contact)
    self.subject_id = contact.id.to_s
    self.subject_type = "OrgContact"
  end
end
