# frozen_string_literal: true

class AddNeyoToTokenStatuses < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      %w(user_token_statuses staff_token_statuses).each do |table|
        next unless table_exists?(table)

        execute <<~SQL.squish
          INSERT INTO #{table} (id)
          VALUES ('NEYO')
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end

  def down
    # No-op to avoid removing shared reference data.
  end
end
