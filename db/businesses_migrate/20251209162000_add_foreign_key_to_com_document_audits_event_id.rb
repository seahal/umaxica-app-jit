class AddForeignKeyToComDocumentAuditsEventId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :com_document_audits, :com_document_audit_events, column: :event_id
  end
end
