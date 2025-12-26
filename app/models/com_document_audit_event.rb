# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ComDocumentAuditEvent < UniversalRecord
  self.table_name = "com_document_audit_events"

  has_many :com_document_audits,
           class_name: "ComDocumentAudit",
           foreign_key: "event_id",
           primary_key: "id",
           inverse_of: :com_document_audit_event,
           dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
end
