# frozen_string_literal: true

class CreateAppDocumentCategoryMasters < ActiveRecord::Migration[8.2]
  def change
    create_table :app_document_category_masters, id: :string, limit: 255 do |t|
      t.string :parent_id, null: false, default: "none", limit: 255

      t.timestamps
    end

    add_index :app_document_category_masters, :parent_id
  end
end
