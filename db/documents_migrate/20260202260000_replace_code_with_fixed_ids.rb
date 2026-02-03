# frozen_string_literal: true

class ReplaceCodeWithFixedIds < ActiveRecord::Migration[8.0]
  def up
    target_tables = {
      app_document_category_masters: {
        1 => "NEYO",
      },
      app_document_statuses: {
        1 => "ACTIVE",
        2 => "ARCHIVED",
        3 => "DELETED",
        4 => "DRAFT",
        5 => "INACTIVE",
        6 => "NEYO",
        7 => "PENDING",
      },
      app_document_tag_masters: {
        1 => "NEYO",
      },
      com_document_category_masters: {
        1 => "NEYO",
      },
      com_document_statuses: {
        1 => "ACTIVE",
        2 => "ARCHIVED",
        3 => "DELETED",
        4 => "DRAFT",
        5 => "INACTIVE",
        6 => "NEYO",
        7 => "PENDING",
      },
      com_document_tag_masters: {
        1 => "NEYO",
      },
      org_document_category_masters: {
        1 => "NEYO",
      },
      org_document_statuses: {
        1 => "ACTIVE",
        2 => "ARCHIVED",
        3 => "DELETED",
        4 => "DRAFT",
        5 => "INACTIVE",
        6 => "NEYO",
        7 => "PENDING",
      },
      org_document_tag_masters: {
        1 => "NEYO",
      },
    }

    safety_assured do
      target_tables.each do |table_name, mapping|
        # Ensure table exists
        unless table_exists?(table_name)
          create_table table_name, id: :bigint do |t|
            t.citext :code, null: false, index: { unique: true }
          end
        end

        # 1. Truncate table and cascade to clear references
        execute "TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE"

        # 2. Insert fixed IDs
        # Check if table has parent_id (for master tables)
        has_parent_id = table_name.to_s.end_with?('_masters')

        mapping.each do |id, code|
          if has_parent_id
            # For master tables with self-referential parent_id, set parent_id to self (root node pattern)
            execute "INSERT INTO #{table_name} (id, code, parent_id) VALUES (#{id}, '#{code}', #{id})"
          else
            execute "INSERT INTO #{table_name} (id, code) VALUES (#{id}, '#{code}')"
          end
        end

        # 3. Update sequence
        max_id = mapping.keys.max
        execute "SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), #{max_id})"

        # 4. Remove code column and index
        remove_column table_name, :code
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
