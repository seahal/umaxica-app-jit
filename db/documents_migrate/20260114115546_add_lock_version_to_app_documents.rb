# frozen_string_literal: true

class AddLockVersionToAppDocuments < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      add_column :app_documents, :lock_version, :integer, null: false, default: 0
    end
  end
end
