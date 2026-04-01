# frozen_string_literal: true

class EnsureSeedReferenceDataInActivity < ActiveRecord::Migration[8.2]
  DATA = {
    app_preference_audit_levels: {
      1 => "INFO",
    },
    com_preference_audit_levels: {
      1 => "INFO",
    },
    org_preference_audit_levels: {
      1 => "INFO",
    },
  }.freeze

  def up
    safety_assured do
      DATA.each do |table_name, mapping|
        upsert_rows(table_name, mapping)
      end
    end
  end

  def down
    # No-op: keep shared reference data in place.
  end

  private

  def upsert_rows(table_name, mapping)
    return unless table_exists?(table_name)

    has_code = column_exists?(table_name, :code)

    mapping.each do |id, code|
      if has_code
        execute(<<~SQL.squish)
          INSERT INTO #{table_name} (id, code)
          VALUES (#{connection.quote(id)}, #{connection.quote(code)})
          ON CONFLICT (id) DO UPDATE SET code = EXCLUDED.code
        SQL
      else
        execute(<<~SQL.squish)
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

    execute("SELECT setval(#{connection.quote(sequence_name)}, #{Integer(max_id)}, true)")
  end
end
