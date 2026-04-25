# frozen_string_literal: true

class AddLockVersionToComAndOrgDocuments < ActiveRecord::Migration[8.2]
  def change
    %i(com_documents org_documents).each do |table_name|
      add_column(table_name, :lock_version, :integer, null: false, default: 0)
    end
  end
end
