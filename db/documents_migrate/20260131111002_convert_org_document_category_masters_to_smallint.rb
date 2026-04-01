# frozen_string_literal: true

require Rails.root.join("lib/migration_helpers/document_tree_smallint")
require Rails.root.join("lib/migration_helpers/document_fk_smallint")

class ConvertOrgDocumentCategoryMastersToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentTreeSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_tree_reference_table(
      table_name: "org_document_category_masters",
      id_sentinel_values: ["NEYO"],
      parent_sentinel_values: %w(NEYO none),
      parent_column: "parent_id",
      lower_index: "index_org_document_category_masters_on_lower_id",
      check_constraint: nil,
      parent_index: "index_org_document_category_masters_on_parent_id",
      child_foreign_keys: [
        { table: :org_document_categories,
          column: :org_document_category_master_id,
          to_table: :org_document_category_masters, },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "org_document_categories",
      column_name: "org_document_category_master_id",
      parent_table: "org_document_category_masters",
      sentinel_values: %w(NEYO none),
      index_name: "idx_on_org_document_category_master_id_0d3d809e93",
      foreign_key_options: {},
    )

    remove_legacy_mapping("org_document_category_masters")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
