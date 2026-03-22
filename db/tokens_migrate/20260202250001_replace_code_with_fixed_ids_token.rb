# frozen_string_literal: true

class ReplaceCodeWithFixedIdsToken < ActiveRecord::Migration[8.0]
  def up
    target_tables = {
      staff_token_kinds: {
        1 => "BROWSER_WEB",
        2 => "CLIENT_IOS",
        3 => "CLIENT_ANDROID",
      },
      staff_token_statuses: {
        1 => "ACTIVE",
        2 => "NEYO",
      },
      user_token_kinds: {
        11 => "BROWSER_WEB",
        12 => "CLIENT_IOS",
        13 => "CLIENT_ANDROID",
      },
      user_token_statuses: {
        1 => "ACTIVE",
        0 => "NEYO",
      },
    }

    safety_assured do
      target_tables.each do |table_name, mapping|
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
