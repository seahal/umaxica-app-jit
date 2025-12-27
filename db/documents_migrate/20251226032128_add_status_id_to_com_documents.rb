# frozen_string_literal: true

class AddStatusIdToComDocuments < ActiveRecord::Migration[8.2]
  def change
    add_column :com_documents, :status_id, :string, limit: 255, null: false, default: "NONE"
    add_index :com_documents, :status_id
  end
end
