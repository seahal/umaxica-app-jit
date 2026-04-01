# frozen_string_literal: true

class ReplaceCodeWithFixedIds < ActiveRecord::Migration[8.0]
  def up
    target_tables = {
      avatar_capabilities: {
        1 => "NORMAL",
      },
      handle_assignment_statuses: {
        1 => "INACTIVE",
        2 => "PENDING",
        3 => "ACTIVE",
        4 => "DELETED",
        5 => "NEYO",
      },
      handle_statuses: {
        1 => "INACTIVE",
        2 => "PENDING",
        3 => "ACTIVE",
        4 => "DELETED",
        5 => "NEYO",
      },
      avatar_membership_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "DELETED",
      },
      avatar_moniker_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "DELETED",
      },
      avatar_ownership_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "DELETED",
      },
      avatar_permissions: {
        1 => "NEYO",
        2 => "READ",
        3 => "WRITE",
        4 => "ADMIN",
      },
      avatar_roles: {
        1 => "NEYO",
        2 => "VIEWER",
        3 => "EDITOR",
        4 => "ADMIN",
      },
      post_review_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "DELETED",
      },
      post_statuses: {
        1 => "NEYO",
        2 => "ACTIVE",
        3 => "INACTIVE",
        4 => "DELETED",
      },
    }

    safety_assured do
      target_tables.each do |table_name, mapping|
        # Ensure table exists
        unless table_exists?(table_name)
          create_table(table_name, id: :bigint) do |t|
            t.citext(:code, null: false, index: { unique: true })
          end
        end

        # 1. Truncate table and cascade to clear references
        execute("TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE")

        # 2. Insert fixed IDs
        mapping.each do |id, code|
          execute("INSERT INTO #{table_name} (id, code) VALUES (#{id}, '#{code}')")
        end

        # 3. Update sequence
        max_id = mapping.keys.max
        execute("SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), #{max_id})")

        # 4. Remove code column and index
        remove_column(table_name, :code)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
