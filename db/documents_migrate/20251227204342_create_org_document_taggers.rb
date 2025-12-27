# frozen_string_literal: true

class CreateOrgDocumentTaggers < ActiveRecord::Migration[8.2]
  def change
    create_table :org_document_taggers, id: :uuid do |t|
      t.references :org_document, null: false, foreign_key: true, type: :uuid
      t.string :org_document_tag_id, null: false, limit: 255

      t.timestamps
    end

    add_index :org_document_taggers,
              [:org_document_id, :org_document_tag_id],
              unique: true,
              name: "index_org_document_taggers_on_document_and_tag"
    add_foreign_key :org_document_taggers, :org_document_tags,
                    column: :org_document_tag_id,
                    primary_key: :id
  end
end
