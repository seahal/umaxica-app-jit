# frozen_string_literal: true

class AddIdFormatConstraintsToDocumentTables < ActiveRecord::Migration[8.2]
  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute(<<~SQL.squish)
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id::text ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute(<<~SQL.squish)
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables_to_constrain
    %w(
      com_documents
      com_document_versions
      app_documents
      app_document_versions
      org_documents
      org_document_versions
      org_document_tags
      org_document_categories
      app_document_tags
      app_document_categories
      com_document_tags
      com_document_categories
    )
  end
end
