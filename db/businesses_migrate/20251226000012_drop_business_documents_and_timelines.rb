class DropBusinessDocumentsAndTimelines < ActiveRecord::Migration[8.2]
  def up
    remove_foreign_key :app_document_audits, :app_documents, if_exists: true
    remove_foreign_key :com_document_audits, :com_documents, if_exists: true
    remove_foreign_key :org_document_audits, :org_documents, if_exists: true
    remove_foreign_key :app_timeline_audits, :app_timelines, if_exists: true
    remove_foreign_key :com_timeline_audits, :com_timelines, if_exists: true
    remove_foreign_key :org_timeline_audits, :org_timelines, if_exists: true

    drop_table :app_document_versions, if_exists: true
    drop_table :com_document_versions, if_exists: true
    drop_table :org_document_versions, if_exists: true
    drop_table :app_timeline_versions, if_exists: true
    drop_table :com_timeline_versions, if_exists: true
    drop_table :org_timeline_versions, if_exists: true

    drop_table :app_documents, if_exists: true
    drop_table :com_documents, if_exists: true
    drop_table :org_documents, if_exists: true
    drop_table :app_timelines, if_exists: true
    drop_table :com_timelines, if_exists: true
    drop_table :org_timelines, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
