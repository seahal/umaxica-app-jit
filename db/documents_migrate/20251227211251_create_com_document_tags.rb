# frozen_string_literal: true

class CreateComDocumentTags < ActiveRecord::Migration[8.2]
  def change
    create_table :com_document_tags, id: :uuid do |t|
      t.references :com_document, null: false, foreign_key: true, type: :uuid
      t.string :com_document_tag_master_id, null: false, limit: 255

      t.timestamps
    end

    add_index :com_document_tags,
              [:com_document_id, :com_document_tag_master_id],
              unique: true,
              name: "index_com_document_tags_on_document_and_tag"
    add_foreign_key :com_document_tags, :com_document_tag_masters,
                    column: :com_document_tag_master_id,
                    primary_key: :id
  end
end
