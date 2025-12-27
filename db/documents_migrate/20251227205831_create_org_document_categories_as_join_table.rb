# frozen_string_literal: true

class CreateOrgDocumentCategoriesAsJoinTable < ActiveRecord::Migration[8.2]
  def change
    create_table :org_document_categories, id: :uuid do |t|
      t.references :org_document, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :org_document_category_master_id, null: false, limit: 255

      t.timestamps
    end

    add_foreign_key :org_document_categories, :org_document_category_masters,
                    column: :org_document_category_master_id,
                    primary_key: :id
  end
end
