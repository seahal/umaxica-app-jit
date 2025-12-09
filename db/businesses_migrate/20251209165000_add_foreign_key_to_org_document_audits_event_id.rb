class AddForeignKeyToOrgDocumentAuditsEventId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :org_document_audits, :org_document_audit_events, column: :event_id
  end
end
