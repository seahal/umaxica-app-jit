# frozen_string_literal: true

require File.expand_path("../../../shared/lib/migration_helpers/document_tree_smallint.rb", __FILE__)
require File.expand_path("../../../shared/lib/migration_helpers/document_fk_smallint.rb", __FILE__)

class ConvertOrgDocumentTagMastersToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentTreeSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_tree_reference_table(
      table_name: "org_document_tag_masters",
      id_sentinel_values: ["NEYO"],
      parent_sentinel_values: %w(NEYO none),
      parent_column: "parent_id",
      lower_index: "index_org_document_tag_masters_on_lower_id",
      check_constraint: nil,
      parent_index: "index_org_document_tag_masters_on_parent_id",
      child_foreign_keys: [
        { table: :org_document_tags, column: :org_document_tag_master_id, to_table: :org_document_tag_masters },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "org_document_tags",
      column_name: "org_document_tag_master_id",
      parent_table: "org_document_tag_masters",
      sentinel_values: %w(NEYO none),
      index_name: "index_org_document_tags_on_org_document_tag_master_id",
      foreign_key_options: {},
    )

    remove_legacy_mapping("org_document_tag_masters")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
