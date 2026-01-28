# frozen_string_literal: true

class ChangeSlugIdLimitInDocuments < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      reversible do |dir|
        dir.up do
          change_column :app_documents, :slug_id, :string, limit: 32
          change_column :com_documents, :slug_id, :string, limit: 32
          change_column :org_documents, :slug_id, :string, limit: 32
        end

        dir.down do
          change_column :app_documents, :slug_id, :string, limit: 255
          change_column :com_documents, :slug_id, :string, limit: 255
          change_column :org_documents, :slug_id, :string, limit: 255
        end
      end
    end
  end
end
