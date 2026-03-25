# frozen_string_literal: true

require Rails.root.join("lib/migration_helpers/document_reference_smallint")
require Rails.root.join("lib/migration_helpers/document_fk_smallint")

class ConvertAppTimelineStatusesToSmallint < ActiveRecord::Migration[8.2]
  include MigrationHelpers::DocumentReferenceSmallint
  include MigrationHelpers::DocumentFkSmallint

  def up
    convert_string_id_pk_table(
      table_name: "app_timeline_statuses",
      sentinel_id: "NEYO",
      lower_index: "index_app_timeline_statuses_on_lower_id",
      check_constraint: "chk_app_timeline_statuses_id_format",
      child_foreign_keys: [
        { table: :app_timelines, column: :status_id, to_table: :app_timeline_statuses },
      ],
    )

    convert_fk_column_to_smallint(
      table_name: "app_timelines",
      column_name: "status_id",
      parent_table: "app_timeline_statuses",
      sentinel_values: %w(NEYO NONE none ""),
      index_name: "index_app_timelines_on_status_id",
    )

    remove_timestamps("app_timeline_statuses")

    remove_legacy_mapping("app_timeline_statuses")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def remove_timestamps(table_name)
    %i(created_at updated_at).each do |column|
      safety_assured {
        safety_assured {
          remove_column(table_name, column, :datetime)
        }
      } if column_exists?(table_name, column)
    end
  end
end
