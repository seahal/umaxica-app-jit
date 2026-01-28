# frozen_string_literal: true

class RemovePermalinkFromAppDocuments < ActiveRecord::Migration[8.2]
  def change
    remove_column :app_documents, :permalink, :string
    remove_column :com_documents, :permalink, :string
    remove_column :org_documents, :permalink, :string
    remove_column :app_documents, :revision_key, :string
    remove_column :com_documents, :revision_key, :string
    remove_column :org_documents, :revision_key, :string
  end
end
