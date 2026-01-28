# frozen_string_literal: true

class AddParentIdToOrgDocumentCategoryMasters < ActiveRecord::Migration[8.2]
  def change
    add_column :org_document_category_masters, :parent_id, :string, null: false, default: "none", limit: 255
    add_index :org_document_category_masters, :parent_id
  end
end
