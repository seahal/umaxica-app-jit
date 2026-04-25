# typed: false
# frozen_string_literal: true

class FixTimelineMastersParentIdNotNull < ActiveRecord::Migration[8.2]
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

    # Create a root row if none exists
    count = connection.select_value("SELECT COUNT(*) FROM #{table}")
    if Integer(count.to_s, 10) == 0
      # Check if code column exists
      if column_exists?(table, :code)
        execute("INSERT INTO #{table} (id, code, parent_id) VALUES (0, 'ROOT', 0) ON CONFLICT DO NOTHING")
      else
        # Only id and parent_id
        execute("INSERT INTO #{table} (id, parent_id) VALUES (0, 0) ON CONFLICT DO NOTHING")
      end
    end

    # Get the minimum id (root)
    root_id = connection.select_value("SELECT MIN(id) FROM #{table}")
    root_id ||= 0

    # Set all NULL parent_id to root_id
    execute("UPDATE #{table} SET parent_id = #{root_id} WHERE parent_id IS NULL")

    # Set NOT NULL constraint
    execute("ALTER TABLE #{table} ALTER COLUMN parent_id SET NOT NULL")

    Rails.logger.debug { "Fixed #{table}.parent_id NOT NULL" }
  rescue => e
    Rails.logger.debug { "Warning fixing #{table}: #{e.message}" }
  end
end
