# frozen_string_literal: true

class SetPublicIdDefaultsAndSeedNullPublicIds < ActiveRecord::Migration[8.2]
  NULL_PUBLIC_ID = "000000000000000000000"
  NULL_UUID = "00000000-0000-0000-0000-000000000000"

  def up
    set_default_empty_string(:handles)
    set_default_empty_string(:avatars)
    set_default_empty_string(:posts)

    ensure_null_public_id_row(:users, :user_identity_status_id)
    ensure_null_public_id_row(:staffs, :staff_identity_status_id)
  end

  def down
    change_column_default :handles, :public_id, from: "", to: nil if column_exists?(:handles, :public_id)
    change_column_default :avatars, :public_id, from: "", to: nil if column_exists?(:avatars, :public_id)
    change_column_default :posts, :public_id, from: "", to: nil if column_exists?(:posts, :public_id)

    delete_null_public_id_row(:users)
    delete_null_public_id_row(:staffs)
  end

  private

  def set_default_empty_string(table)
    return unless column_exists?(table, :public_id)

    change_column_default table, :public_id, from: nil, to: ""
  end

  def ensure_null_public_id_row(table, status_column)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (id, public_id, #{status_column}, created_at, updated_at)
        VALUES ('#{NULL_UUID}', '#{NULL_PUBLIC_ID}', 'NEYO', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT DO NOTHING
      SQL
    end
  end

  def delete_null_public_id_row(table)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM #{table}
        WHERE public_id = '#{NULL_PUBLIC_ID}' AND id = '#{NULL_UUID}'
      SQL
    end
  end
end
