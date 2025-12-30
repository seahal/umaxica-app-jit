# frozen_string_literal: true

class RemovePositionFromDocumentStatuses < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      %i(app_document_statuses com_document_statuses org_document_statuses).each do |table|
        remove_column table, :position, :integer if column_exists?(table, :position)
      end
    end
  end
end
