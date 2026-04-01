# frozen_string_literal: true

class ReplaceCodeWithFixedIds < ActiveRecord::Migration[8.0]
  def up
    target_tables = {
      app_preference_colortheme_options: {
        1 => "LIGHT",
        2 => "DARK",
        3 => "SYSTEM",
      },
      app_preference_language_options: {
        1 => "JA",
        2 => "EN",
      },
      app_preference_region_options: {
        1 => "US",
        2 => "JP",
      },
      app_preference_statuses: {
        1 => "DELETED",
        2 => "NEYO",
      },
      app_preference_timezone_options: {
        1 => "ETC/UTC",
        2 => "ASIA/TOKYO",
      },
      com_preference_colortheme_options: {
        1 => "LIGHT",
        2 => "DARK",
        3 => "SYSTEM",
      },
      com_preference_language_options: {
        1 => "JA",
        2 => "EN",
      },
      com_preference_region_options: {
        1 => "US",
        2 => "JP",
      },
      com_preference_statuses: {
        1 => "DELETED",
        2 => "NEYO",
      },
      com_preference_timezone_options: {
        1 => "ETC/UTC",
        2 => "ASIA/TOKYO",
      },
      org_preference_colortheme_options: {
        1 => "LIGHT",
        2 => "DARK",
        3 => "SYSTEM",
      },
      org_preference_language_options: {
        1 => "JA",
        2 => "EN",
      },
      org_preference_region_options: {
        1 => "US",
        2 => "JP",
      },
      org_preference_statuses: {
        1 => "DELETED",
        2 => "NEYO",
      },
      org_preference_timezone_options: {
        1 => "ETC/UTC",
        2 => "ASIA/TOKYO",
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
