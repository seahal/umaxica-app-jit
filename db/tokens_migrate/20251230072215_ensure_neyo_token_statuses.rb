# frozen_string_literal: true

class EnsureNeyoTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    %w(user_token_statuses staff_token_statuses).each do |table|
      next unless table_exists?(table)

      safety_assured do
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
