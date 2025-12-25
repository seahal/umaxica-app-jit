# == Schema Information
#
# Table name: app_contact_histories
#
#  id             :uuid             not null, primary key
#  actor_id       :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type     :string           default(""), not null
#  app_contact_id :uuid             not null
#  created_at     :datetime         not null
#  event_id       :string(255)      default("NONE"), not null
#  parent_id      :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  position       :integer          default(0), not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_app_contact_histories_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_app_contact_histories_on_app_contact_id           (app_contact_id)
#  index_app_contact_histories_on_parent_id                (parent_id)
#

class AppContactAudit < GuestsRecord
  # Use existing table `app_contact_histories` for storage to avoid a migration
  # and keep backward compatibility with previously-named table.
  self.table_name = "app_contact_histories"

  belongs_to :app_contact
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :app_contact_audit_event,
             class_name: "AppContactAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_contact_audits

  belongs_to :app_contact_audit_level,
             foreign_key: :level_id,
             inverse_of: :app_contact_audits

  validates :event_id, length: { maximum: 255 }
  validates :level_id, length: { maximum: 255 }

  # This model tracks the audit/history of contact interactions
end
