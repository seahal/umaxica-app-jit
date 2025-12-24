# == Schema Information
#
# Table name: org_contact_histories
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  org_contact_id :uuid             not null
#  parent_id      :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  position       :integer          default(0), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_org_contact_histories_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_org_contact_histories_on_org_contact_id           (org_contact_id)
#  index_org_contact_histories_on_parent_id                (parent_id)
#

class OrgContactAudit < GuestsRecord
  # Use existing table `org_contact_histories` for storage to avoid a migration
  # and keep backward compatibility with previously-named table.
  self.table_name = "org_contact_histories"

  belongs_to :org_contact
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :org_contact_audit_event,
             class_name: "OrgContactAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_contact_audits

  # This model tracks the audit/history of contact interactions
end
