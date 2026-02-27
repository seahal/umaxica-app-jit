# frozen_string_literal: true

class AddFixedIdsToTimelineTables < ActiveRecord::Migration[8.0]
  def up
    target_tables = {
      app_timeline_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "PENDING",
        5 => "DELETED",
        6 => "DRAFT",
        7 => "ARCHIVED",
      },
      app_timeline_category_masters: {
        1 => "NEYO",
      },
      app_timeline_tag_masters: {
        1 => "NEYO",
      },
      com_timeline_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "PENDING",
        5 => "DELETED",
        6 => "DRAFT",
        7 => "ARCHIVED",
      },
      com_timeline_category_masters: {
        1 => "NEYO",
      },
      com_timeline_tag_masters: {
        1 => "NEYO",
      },
      org_timeline_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "PENDING",
        5 => "DELETED",
        6 => "DRAFT",
        7 => "ARCHIVED",
      },
      org_timeline_category_masters: {
        1 => "NEYO",
      },
      org_timeline_tag_masters: {
        1 => "NEYO",
      },
    }

    safety_assured do
      target_tables.each do |table_name, mapping|
        # 1. Truncate table and cascade to clear references
        execute "TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE"

        # 2. Insert fixed IDs
        # Check if table has parent_id (for master tables)
        has_parent_id = table_name.to_s.end_with?('_masters')

        mapping.each do |id, _code|
          if has_parent_id
            # For master tables with self-referential parent_id, set parent_id to id (root node pattern)
            # Note: Code column doesn't exist in these tables - we're just inserting the initial data
            execute "INSERT INTO #{table_name} (id, parent_id) VALUES (#{id}, #{id})"
          else
            # For status tables - these tables also don't have code column yet
            # Just insert the id to establish the fixed IDs
            execute "INSERT INTO #{table_name} (id) VALUES (#{id})"
          end
        end

        # 3. Update sequence
        max_id = mapping.keys.max
        execute "SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), #{max_id})"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
