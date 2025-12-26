class CreateOrgDocumentVersions < ActiveRecord::Migration[8.2]
  def change
    create_table :org_document_versions, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :org_document, null: false, foreign_key: true, type: :uuid
      t.string :permalink, null: false, limit: 200
      t.string :response_mode, null: false
      t.string :redirect_url
      t.string :title
      t.string :description
      t.text :body
      t.datetime :published_at, null: false
      t.datetime :expires_at, null: false
      t.string :edited_by_type
      t.bigint :edited_by_id
      t.timestamps
    end

    add_index :org_document_versions, [:org_document_id, :created_at]
  end
end
