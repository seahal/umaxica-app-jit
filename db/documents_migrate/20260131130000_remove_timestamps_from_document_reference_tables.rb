# frozen_string_literal: true

class RemoveTimestampsFromDocumentReferenceTables < ActiveRecord::Migration[8.2]
  REFERENCE_TABLES = %w(
    app_document_statuses
    com_document_statuses
    org_document_statuses
    app_document_category_masters
    com_document_category_masters
    org_document_category_masters
    app_document_tag_masters
    com_document_tag_masters
    org_document_tag_masters
  ).freeze
  TIMESTAMP_COLUMNS = %i(created_at updated_at).freeze

  def up
    REFERENCE_TABLES.each do |table|
      TIMESTAMP_COLUMNS.each do |column|
        safety_assured { remove_column table, column, :datetime } if column_exists?(table, column)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
