# frozen_string_literal: true

class AlignTokenStatusIdsWithModelConstants < ActiveRecord::Migration[8.2]
  STAFF_STATUS_IDS = {
    0 => "NEYO",
    1 => "ACTIVE",
    2 => "EXPIRED",
  }.freeze

  USER_STATUS_IDS = {
    0 => "NEYO",
    1 => "ACTIVE",
    2 => "EXPIRED",
  }.freeze

  def up
    safety_assured do
      align_staff_token_statuses!
      align_user_token_statuses!
    end
  end

  def down
    # Keep reference IDs stable.
  end

  private

  def align_staff_token_statuses!
    return unless table_exists?(:staff_token_statuses)

    # Legacy environments used id=2 as NEYO. Move staff_tokens to id=0 first.
    unless row_exists?(:staff_token_statuses, 0)
      if row_exists?(:staff_token_statuses, 2)
        execute <<~SQL.squish
          UPDATE staff_tokens
          SET staff_token_status_id = 0
          WHERE staff_token_status_id = 2
        SQL

        execute <<~SQL.squish
          DELETE FROM staff_token_statuses
          WHERE id = 2
        SQL
      end
    end

    upsert_rows(:staff_token_statuses, STAFF_STATUS_IDS)
  end

  def align_user_token_statuses!
    return unless table_exists?(:user_token_statuses)

    upsert_rows(:user_token_statuses, USER_STATUS_IDS)
  end

  def row_exists?(table_name, id)
    select_value("SELECT 1 FROM #{table_name} WHERE id = #{connection.quote(id)} LIMIT 1").present?
  end

  def upsert_rows(table_name, mapping)
    has_code = column_exists?(table_name, :code)

    mapping.each do |id, code|
      if has_code
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id, code)
          VALUES (#{connection.quote(id)}, #{connection.quote(code)})
          ON CONFLICT (id) DO UPDATE SET code = EXCLUDED.code
        SQL
      else
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id)
          VALUES (#{connection.quote(id)})
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end

    ensure_sequence!(table_name, mapping.keys.max)
  end

  def ensure_sequence!(table_name, max_id)
    sequence_name = select_value("SELECT pg_get_serial_sequence(#{connection.quote(table_name.to_s)}, 'id')")
    return if sequence_name.blank?

    execute "SELECT setval(#{connection.quote(sequence_name)}, #{Integer(max_id)}, true)"
  end
end
