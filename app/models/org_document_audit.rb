# == Schema Information
#
# Table name: org_document_audits
#
#  id              :uuid             not null, primary key
#  actor_id        :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  actor_type      :string           default(""), not null
#  created_at      :datetime         not null
#  current_value   :text             default(""), not null
#  event_id        :string(255)      default(""), not null
#  ip_address      :string           default(""), not null
#  level_id        :string           default("NONE"), not null
#  org_document_id :uuid             not null
#  previous_value  :text             default(""), not null
#  timestamp       :datetime         default("-infinity"), not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_org_document_audits_on_actor_type_and_actor_id  (actor_type,actor_id)
#  index_org_document_audits_on_level_id                 (level_id)
#  index_org_document_audits_on_org_document_id          (org_document_id)
#

class OrgDocumentAudit < BusinessesRecord
  self.table_name = "org_document_audits"

  belongs_to :org_document
  belongs_to :actor, polymorphic: true, optional: true

  belongs_to :org_document_audit_level, foreign_key: :level_id, inverse_of: :org_document_audits
  belongs_to :org_document_audit_event,
             class_name: "OrgDocumentAuditEvent",
             foreign_key: "event_id",
             primary_key: "id",
             inverse_of: :org_document_audits
end
