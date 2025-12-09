class CreateOrgDocumentStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :org_document_statuses, id: :string, limit: 255 do |t|
      t.timestamps
    end

    execute "ALTER TABLE org_document_statuses ALTER COLUMN id SET DEFAULT 'NONE'"
  end

  def down
    drop_table :org_document_statuses
  end
end
