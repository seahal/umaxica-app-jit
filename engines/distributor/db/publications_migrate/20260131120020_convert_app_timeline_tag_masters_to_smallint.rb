# typed: false
# frozen_string_literal: true

require File.expand_path("../../../../../shared/lib/migration_helpers/document_tree_smallint.rb", __FILE__)
require File.expand_path("../../../../../shared/lib/migration_helpers/document_fk_smallint.rb", __FILE__)

class ConvertAppTimelineTagMastersToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentTreeSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_tree_reference_table(
      table_name: "app_timeline_tag_masters",
      id_sentinel_values: %w(NEYO NONE none ""),
      parent_sentinel_values: %w(NEYO NONE none ""),
      parent_column: "parent_id",
      lower_index: "index_app_timeline_tag_masters_on_lower_id",
      check_constraint: nil,
      parent_index: "index_app_timeline_tag_masters_on_parent_id",
      child_foreign_keys: [
        { table: :app_timeline_tags, column: :app_timeline_tag_master_id, to_table: :app_timeline_tag_masters },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "app_timeline_tags",
      column_name: "app_timeline_tag_master_id",
      parent_table: "app_timeline_tag_masters",
      sentinel_values: %w(NEYO NONE none ""),
      index_name: "index_app_timeline_tags_on_app_timeline_tag_master_id",
    )

    remove_timestamps("app_timeline_tag_masters")

    remove_legacy_mapping("app_timeline_tag_masters")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def remove_timestamps(table_name)
    %i(created_at updated_at).each do |column|
      safety_assured { remove_column(table_name, column, :datetime) } if column_exists?(table_name, column)
    end
  end
end
