# frozen_string_literal: true

require Rails.root.join("lib/migration_helpers/document_tree_smallint")
require Rails.root.join("lib/migration_helpers/document_fk_smallint")

class ConvertComTimelineCategoryMastersToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentTreeSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_tree_reference_table(
      table_name: "com_timeline_category_masters",
      id_sentinel_values: %w(NEYO NONE none ""),
      parent_sentinel_values: %w(NEYO NONE none ""),
      parent_column: "parent_id",
      lower_index: "index_com_timeline_category_masters_on_lower_id",
      check_constraint: nil,
      parent_index: "index_com_timeline_category_masters_on_parent_id",
      child_foreign_keys: [
        { table: :com_timeline_categories, column: :com_timeline_category_master_id, to_table: :com_timeline_category_masters },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "com_timeline_categories",
      column_name: "com_timeline_category_master_id",
      parent_table: "com_timeline_category_masters",
      sentinel_values: %w(NEYO NONE none ""),
      index_name: "idx_on_com_timeline_category_master_id_3ab8427d3a",
    )

    remove_timestamps("com_timeline_category_masters")

    remove_legacy_mapping("com_timeline_category_masters")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def remove_timestamps(table_name)
    %i[created_at updated_at].each do |column|
      safety_assured { remove_column table_name, column, :datetime } if column_exists?(table_name, column)
    end
  end
end
