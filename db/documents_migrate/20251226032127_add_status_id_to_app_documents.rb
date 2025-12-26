class AddStatusIdToAppDocuments < ActiveRecord::Migration[8.2]
  def change
    add_column :app_documents, :status_id, :string, limit: 255, null: false, default: "NONE"
    add_index :app_documents, :status_id
  end
end
