# frozen_string_literal: true

class CreateOrgDocumentCategoryMasters < ActiveRecord::Migration[8.2]
  def change
    create_table :org_document_category_masters, id: :string, limit: 255 do |t|
      t.timestamps
    end
  end
end
