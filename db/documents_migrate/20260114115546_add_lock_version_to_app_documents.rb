# frozen_string_literal: true

class AddLockVersionToAppDocuments < ActiveRecord::Migration[8.2]
  def change
    add_column :app_documents, :lock_version, :integer, null: false, default: 0
  end
end
