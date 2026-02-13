# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_behaviors
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
#  idx_on_subject_type_subject_id_occurred_at_f6fc919b48     (subject_type,subject_id,occurred_at)
#  index_org_document_behaviors_on_actor_id_and_occurred_at  (actor_id,occurred_at)
#  index_org_document_behaviors_on_event_id                  (event_id)
#  index_org_document_behaviors_on_expires_at                (expires_at)
#  index_org_document_behaviors_on_level_id                  (level_id)
#  index_org_document_behaviors_on_occurred_at               (occurred_at)
#  index_org_document_behaviors_on_subject_id                (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_id => org_document_behavior_events.id)
#  fk_rails_...  (level_id => org_document_behavior_levels.id)
#

class OrgDocumentBehavior < ActivityRecord
  # Virtual belongs_to for ERD - uses subject_id/subject_type instead of FK
  belongs_to :org_document, optional: true, foreign_key: :subject_id, inverse_of: :org_document_behaviors
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :org_document_behavior_level, foreign_key: :level_id, inverse_of: :org_document_behaviors
  belongs_to :org_document_behavior_event,
             class_name: "OrgDocumentBehaviorEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_document_behaviors
  validates :subject_id, presence: true
  validates :subject_type, presence: true

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  def org_document
    OrgDocument.find(subject_id) if subject_type == "OrgDocument"
  end

  def org_document=(doc)
    self.subject_id = doc.id.to_s
    self.subject_type = "OrgDocument"
  end
end
