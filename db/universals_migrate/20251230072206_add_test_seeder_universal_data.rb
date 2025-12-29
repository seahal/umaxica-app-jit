# frozen_string_literal: true

class AddTestSeederUniversalData < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Insert missing occurrence statuses needed by TestSeeder
      occurrence_status_ids = %w(NEYO)
      %w(area domain email ip telephone zip staff user).each do |prefix|
        table_name = "#{prefix}_occurrence_statuses"
        next unless table_exists?(table_name)

        occurrence_status_ids.each do |id|
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
