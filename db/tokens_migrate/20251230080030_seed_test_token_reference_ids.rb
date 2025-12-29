# frozen_string_literal: true

class SeedTestTokenReferenceIds < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  NEYO_ID_TABLES = %w(
    user_token_statuses
  ).freeze

  def up
    safety_assured do
      NEYO_ID_TABLES.each do |table|
        seed_id(table, "NEYO")
      end
    end
  end

  def down
    # No-op to avoid removing shared reference data.
  end

  private

  def seed_id(table_name, id)
    return unless table_exists?(table_name)

    cols = ["id"]
    vals = [connection.quote(id)]

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
