# frozen_string_literal: true

class CreateComDocumentVersions < ActiveRecord::Migration[8.2]
  def change
    create_table :com_document_versions do |t|
      t.references :com_document, null: false, foreign_key: true, type: :bigint
      t.string :permalink, null: false, limit: 200
      t.string :response_mode, null: false
      t.string :redirect_url
      t.string :title
      t.string :description
      t.text :body
      t.datetime :published_at, null: false
      t.datetime :expires_at, null: false
      t.string :edited_by_type
      t.bigint :edited_by_id
      t.timestamps
    end

    add_index :com_document_versions, [:com_document_id, :created_at]
  end
end
