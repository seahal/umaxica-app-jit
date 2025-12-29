# frozen_string_literal: true

class SeedTestTokens < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  USER_TOKENS = [
    { id: "00000000-0000-0000-0000-000000200001", user_id: "00000000-0000-0000-0000-000000000001", public_id: "utoken_one" },
    { id: "00000000-0000-0000-0000-000000200002", user_id: "00000000-0000-0000-0000-000000000002", public_id: "utoken_two" },
  ].freeze

  STAFF_TOKENS = [
    { id: "00000000-0000-0000-0000-000000210001", staff_id: "00000000-0000-0000-0000-000000100001", public_id: "stoken_one" },
    { id: "00000000-0000-0000-0000-000000210002", staff_id: "00000000-0000-0000-0000-000000100001", public_id: "stoken_two" },
  ].freeze

  def up
    safety_assured do
      seed_tokens(:user_tokens, USER_TOKENS, fk_column: :user_id, status_column: :user_token_status_id)
      seed_tokens(:staff_tokens, STAFF_TOKENS, fk_column: :staff_id, status_column: :staff_token_status_id)
    end
  end

  def down
    # No-op to avoid deleting shared reference data used in tests.
  end

  private

  def seed_tokens(table, rows, fk_column:, status_column:)
    return unless table_exists?(table)

    now_sql = "CURRENT_TIMESTAMP"
    refresh_exp_sql = "CURRENT_TIMESTAMP + interval '90 days'"

    rows.each do |row|
      execute <<~SQL.squish
        INSERT INTO #{table} (id, public_id, #{fk_column}, #{status_column}, refresh_expires_at, created_at, updated_at)
        VALUES ('#{row[:id]}', '#{row[:public_id]}', '#{row[fk_column]}', 'NEYO', #{refresh_exp_sql}, #{now_sql}, #{now_sql})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
