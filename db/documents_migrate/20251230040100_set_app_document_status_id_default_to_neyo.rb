# frozen_string_literal: true

class SetAppDocumentStatusIdDefaultToNeyo < ActiveRecord::Migration[7.1]
  def up
    return unless table_exists?(:app_document_statuses)

    change_column_default :app_document_statuses, :id, from: "NONE", to: "NEYO"
  end

  def down
    return unless table_exists?(:app_document_statuses)

    change_column_default :app_document_statuses, :id, from: "NEYO", to: "NONE"
  end
end
