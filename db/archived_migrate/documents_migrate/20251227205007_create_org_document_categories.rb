# frozen_string_literal: true

class CreateOrgDocumentCategories < ActiveRecord::Migration[8.2]
  def change
    create_table(:org_document_categories) do |t|
      t.references(:org_document, null: false, foreign_key: true, type: :bigint, index: { unique: true })
      t.string(:category_id, null: false, limit: 255)

      t.timestamps
    end
  end
end
