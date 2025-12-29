# frozen_string_literal: true

class SeedTestAccounts < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  USERS = [
    { id: "00000000-0000-0000-0000-000000000001", public_id: "user_one", status_id: "ALIVE" },
    { id: "00000000-0000-0000-0000-000000000002", public_id: "user_two", status_id: "ALIVE" },
    { id: "00000000-0000-0000-0000-000000000010", public_id: "user_none", status_id: "NEYO" },
  ].freeze

  STAFFS = [
    { id: "00000000-0000-0000-0000-000000100001", public_id: "staff_one", status_id: "ALIVE" },
    { id: "00000000-0000-0000-0000-000000100010", public_id: "staff_none", status_id: "NEYO" },
  ].freeze

  def up
    safety_assured do
      seed_people(:users, USERS)
      seed_people(:staffs, STAFFS)
    end
  end

  def down
    # No-op to avoid deleting shared reference data used in tests.
  end

  private

  def seed_people(table, rows)
    return unless table_exists?(table)

    now_sql = connection.quote(Time.current)
    status_column =
      case table.to_s
      when "users" then "user_identity_status_id"
      when "staffs" then "staff_identity_status_id"
      else "status_id"
      end

    rows.each do |row|
      execute <<~SQL.squish
        INSERT INTO #{table} (id, public_id, #{status_column}, created_at, updated_at, webauthn_id)
        VALUES ('#{row[:id]}', '#{row[:public_id]}', '#{row[:status_id]}', #{now_sql}, #{now_sql}, '')
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
