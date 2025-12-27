# frozen_string_literal: true

class CreateAppDocumentTags < ActiveRecord::Migration[8.2]
  def change
    create_table :app_document_tags, id: :uuid do |t|
      t.references :app_document, null: false, foreign_key: true, type: :uuid
      t.string :app_document_tag_master_id, null: false, limit: 255

      t.timestamps
    end

    add_index :app_document_tags,
              [:app_document_id, :app_document_tag_master_id],
              unique: true,
              name: "index_app_document_tags_on_document_and_tag"
    add_foreign_key :app_document_tags, :app_document_tag_masters,
                    column: :app_document_tag_master_id,
                    primary_key: :id
  end
end
