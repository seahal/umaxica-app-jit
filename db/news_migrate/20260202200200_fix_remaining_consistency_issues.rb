# frozen_string_literal: true

class FixRemainingConsistencyIssues < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TIMELINE_MASTERS = %w(
    org_timeline_tag_masters
    org_timeline_category_masters
    com_timeline_tag_masters
    com_timeline_category_masters
    app_timeline_tag_masters
    app_timeline_category_masters
  ).freeze

  def up
    safety_assured do
      # 1. Fix Timeline master parent_id NOT NULL
      TIMELINE_MASTERS.each do |table|
        fix_parent_id_not_null(table)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_parent_id_not_null(table)
    return unless table_exists?(table) && column_exists?(table, :parent_id)

    # Check current state
    nullable = connection.select_value(<<~SQL.squish)
      SELECT is_nullable FROM information_schema.columns#{" "}
      WHERE table_name = '#{table}' AND column_name = 'parent_id'
    SQL

    return if nullable == 'NO' # Already NOT NULL

    # Set all NULL parent_id to 0 (assuming 0 is always valid as root)
    execute "UPDATE #{table} SET parent_id = 0 WHERE parent_id IS NULL"

    # Set NOT NULL constraint
    execute "ALTER TABLE #{table} ALTER COLUMN parent_id SET NOT NULL"

    Rails.logger.debug { "Fixed #{table}.parent_id NOT NULL" }
  rescue => e
    Rails.logger.debug { "Warning fixing #{table}: #{e.message}" }
  end
end
