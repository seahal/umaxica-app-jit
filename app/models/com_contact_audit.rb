# == Schema Information
#
# Table name: com_contact_audits
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  com_contact_id :uuid             not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  parent_id      :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  position       :integer          default(0), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_com_contact_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_com_contact_audits_on_com_contact_id           (com_contact_id)
#

class ComContactAudit < GuestsRecord
  belongs_to :com_contact
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :com_contact_audit_event,
             class_name: "ComContactAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :com_contact_audits

  validates :event_id, length: { maximum: 255 }

  # This model tracks the audit/history of contact interactions
end
