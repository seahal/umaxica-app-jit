class AddForeignKeyToAppDocumentAuditsEventId < ActiveRecord::Migration[8.2]
  def change
    add_foreign_key :app_document_audits, :app_document_audit_events, column: :event_id
  end
end
