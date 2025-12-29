# frozen_string_literal: true

class AddTestSeederNewsData < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!
  STATUS_IDS = %w(NEYO ACTIVE).freeze

  def up
    safety_assured do
      # Insert missing timeline statuses needed by TestSeeder
      %w(app com org).each do |prefix|
        table_name = "#{prefix}_timeline_statuses"
        next unless table_exists?(table_name)

        STATUS_IDS.each do |id|
          cols = []
          vals = []

          cols << "id"
          vals << connection.quote(id)

          if column_exists?(table_name, :active)
            cols << "active"
            vals << "TRUE"
          end

          if column_exists?(table_name, :position)
            cols << "position"
            vals << "0"
          end

          if column_exists?(table_name, :created_at)
            cols << "created_at"
            vals << "CURRENT_TIMESTAMP"
          end

          if column_exists?(table_name, :updated_at)
            cols << "updated_at"
            vals << "CURRENT_TIMESTAMP"
          end

          execute <<~SQL.squish
            INSERT INTO #{table_name} (#{cols.join(", ")})
            VALUES (#{vals.join(", ")})
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      end
    end
  end

  def down
    # No-op - we don't want to delete reference data
  end
end
