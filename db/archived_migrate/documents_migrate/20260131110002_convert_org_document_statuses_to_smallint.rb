# frozen_string_literal: true

require File.expand_path("../../../shared/lib/migration_helpers/document_reference_smallint.rb", __FILE__)
require File.expand_path("../../../shared/lib/migration_helpers/document_fk_smallint.rb", __FILE__)

class ConvertOrgDocumentStatusesToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentReferenceSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_string_id_pk_table(
      table_name: "org_document_statuses",
      sentinel_id: "NEYO",
      lower_index: "index_org_document_statuses_on_lower_id",
      check_constraint: "chk_org_document_statuses_id_format",
      child_foreign_keys: [
        { table: :org_documents, column: :status_id, to_table: :org_document_statuses },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "org_documents",
      column_name: "status_id",
      parent_table: "org_document_statuses",
      sentinel_values: ["NEYO"],
      index_name: "index_org_documents_on_status_id",
      foreign_key_options: { validate: false },
    )

    remove_legacy_mapping("org_document_statuses")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
