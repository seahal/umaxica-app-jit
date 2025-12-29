# frozen_string_literal: true

class RemoveDescriptionFromDocumentStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :app_document_statuses, :description, :string
      remove_column :com_document_statuses, :description, :string
      remove_column :org_document_statuses, :description, :string
    end
  end
end
