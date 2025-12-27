# frozen_string_literal: true

class DropOrgDocumentCategories < ActiveRecord::Migration[8.2]
  def change
    drop_table :org_document_categories, if_exists: true do |t|
      t.uuid :org_document_id, null: false
      t.string :org_document_category_master_id, null: false, limit: 255

      t.timestamps
    end
  end
end
