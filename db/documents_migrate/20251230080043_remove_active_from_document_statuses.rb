# frozen_string_literal: true

class RemoveActiveFromDocumentStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      remove_column :org_document_statuses, :active, :boolean
      remove_column :com_document_statuses, :active, :boolean
      remove_column :app_document_statuses, :active, :boolean
    end
  end
end
