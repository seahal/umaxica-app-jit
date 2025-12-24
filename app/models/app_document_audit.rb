# == Schema Information
#
# Table name: app_document_audits
#
#  id              :uuid             not null, primary key
#  actor_id        :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type      :string           default(""), not null
#  app_document_id :uuid             not null
#  created_at      :datetime         not null
#  current_value   :text             default(""), not null
#  event_id        :string(255)      default(""), not null
#  ip_address      :string           default(""), not null
#  level_id        :string           default("NONE"), not null
#  previous_value  :text             default(""), not null
#  timestamp       :datetime         default("-infinity"), not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_app_document_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_app_document_audits_on_app_document_id          (app_document_id)
#  index_app_document_audits_on_level_id                 (level_id)
#

class AppDocumentAudit < BusinessesRecord
  self.table_name = "app_document_audits"

  belongs_to :app_document
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :app_document_audit_level, foreign_key: :level_id, inverse_of: :app_document_audits
  # event_id references AppDocumentAuditEvent.id (string)
  belongs_to :app_document_audit_event,
             class_name: "AppDocumentAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :app_document_audits

  validates :event_id, length: { maximum: 255 }
end
