# frozen_string_literal: true

class SeedNeyoUserIdentityPasskeyStatus < ActiveRecord::Migration[8.2]
  def up
    seed_id(:user_identity_passkey_statuses, "NEYO")
  end

  def down
    # No-op to avoid removing shared reference data
  end

  private

  def seed_id(table_name, id)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    safety_assured do
      if has_timestamps
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id, created_at, updated_at)
          VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ON CONFLICT (id) DO NOTHING
        SQL
      else
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id)
          VALUES ('#{id}')
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end
end
