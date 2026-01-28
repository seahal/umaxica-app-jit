# frozen_string_literal: true

class AddPublicIdToDocuments < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :app_documents, :public_id, :string, limit: 21, default: "", null: false
    add_column :com_documents, :public_id, :string, limit: 21, default: "", null: false
    add_column :org_documents, :public_id, :string, limit: 21, default: "", null: false

    add_index :app_documents, :public_id, algorithm: :concurrently
    add_index :com_documents, :public_id, algorithm: :concurrently
    add_index :org_documents, :public_id, algorithm: :concurrently
  end
end
