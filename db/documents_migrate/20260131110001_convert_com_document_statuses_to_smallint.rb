# frozen_string_literal: true

require Rails.root.join("lib/migration_helpers/document_reference_smallint")
require Rails.root.join("lib/migration_helpers/document_fk_smallint")

class ConvertComDocumentStatusesToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentReferenceSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_string_id_pk_table(
      table_name: "com_document_statuses",
      sentinel_id: "NEYO",
      lower_index: "index_com_document_statuses_on_lower_id",
      check_constraint: "chk_com_document_statuses_id_format",
      child_foreign_keys: [
        { table: :com_documents, column: :status_id, to_table: :com_document_statuses },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "com_documents",
      column_name: "status_id",
      parent_table: "com_document_statuses",
      sentinel_values: ["NEYO"],
      index_name: "index_com_documents_on_status_id",
      foreign_key_options: { validate: false },
    )

    remove_legacy_mapping("com_document_statuses")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
