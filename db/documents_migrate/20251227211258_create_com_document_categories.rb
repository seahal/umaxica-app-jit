# frozen_string_literal: true

class CreateComDocumentCategories < ActiveRecord::Migration[8.2]
  def change
    create_table :com_document_categories, id: :uuid do |t|
      t.references :com_document, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :com_document_category_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :com_document_categories, :com_document_category_masters,
                    column: :com_document_category_master_id,
                    primary_key: :id
  end
end
