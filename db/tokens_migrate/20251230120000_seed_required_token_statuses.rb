# frozen_string_literal: true

class SeedRequiredTokenStatuses < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      insert_statuses("user_token_statuses")
      insert_statuses("staff_token_statuses")
    end
  end

  def down
    safety_assured do
      delete_statuses("user_token_statuses")
      delete_statuses("staff_token_statuses")
    end
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
