# frozen_string_literal: true

class SeedRequiredTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end

  private

  def insert_statuses(table_name)
    return unless table_exists?(table_name)

    execute <<~SQL.squish
      INSERT INTO #{table_name} (id)
      VALUES ('NEYO'), ('ACTIVE')
      ON CONFLICT (id) DO NOTHING;
    SQL
  end

  def delete_statuses(table_name)
    return unless table_exists?(table_name)

    execute "DELETE FROM #{table_name} WHERE id IN ('NEYO', 'ACTIVE');"
  end
end
