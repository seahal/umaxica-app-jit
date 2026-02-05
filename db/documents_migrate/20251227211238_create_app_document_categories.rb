# frozen_string_literal: true

class CreateAppDocumentCategories < ActiveRecord::Migration[8.2]
  def change
    create_table :app_document_categories do |t|
      t.references :app_document, null: false, foreign_key: true, type: :bigint, index: { unique: true }
      t.string :app_document_category_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :app_document_categories, :app_document_category_masters,
                    column: :app_document_category_master_id,
                    primary_key: :id
  end
end
