# frozen_string_literal: true

class RebuildOrgDocuments < ActiveRecord::Migration[8.2]
  def up
    drop_table :org_documents, if_exists: true

    create_table :org_documents, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :permalink, null: false, limit: 200
      t.string :response_mode, null: false, default: "html"
      t.string :redirect_url
      t.string :revision_key, null: false
      t.datetime :published_at, null: false, default: -> { "'infinity'" }
      t.datetime :expires_at, null: false, default: -> { "'infinity'" }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :org_documents, :permalink, unique: true
    add_index :org_documents, [:published_at, :expires_at]
  end

  def down
    drop_table :org_documents, if_exists: true

    create_table :org_documents, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.uuid :parent_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.uuid :prev_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.uuid :succ_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.string :title, null: false, default: ""
      t.string :description, null: false, default: ""
      t.string :org_document_status_id, limit: 255, null: false, default: "NONE"
      t.uuid :staff_id, null: false, default: "00000000-0000-0000-0000-000000000000"
      t.string :public_id, limit: 21, null: false, default: ""
      t.timestamps
    end

    add_index :org_documents, :org_document_status_id
    add_index :org_documents, :parent_id
    add_index :org_documents, :prev_id
    add_index :org_documents, :succ_id
    add_index :org_documents, :staff_id
    add_index :org_documents, :public_id
  end
end
