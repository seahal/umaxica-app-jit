# frozen_string_literal: true

class EnsureFixedIdsInPreferenceColorthemeOptions < ActiveRecord::Migration[8.2]
  DATA = {
    app_preference_colortheme_options: [0, 1, 2, 3],
    com_preference_colortheme_options: [1, 2, 3],
    org_preference_colortheme_options: [1, 2, 3],
  }.freeze

  def up
    safety_assured do
      DATA.each do |table_name, ids|
        next unless table_exists?(table_name)

        ids.each do |id|
          execute(<<~SQL.squish)
            INSERT INTO #{table_name} (id)
            VALUES (#{connection.quote(id)})
            ON CONFLICT (id) DO NOTHING
          SQL
        end

        ensure_sequence!(table_name, ids.max)
      end
    end
  end

  def down
    # No-op: keep shared reference data in place.
  end

  private

  def ensure_sequence!(table_name, max_id)
    sequence_name = select_value("SELECT pg_get_serial_sequence(#{connection.quote(table_name.to_s)}, 'id')")
    return if sequence_name.blank?

    execute("SELECT setval(#{connection.quote(sequence_name)}, #{Integer(max_id)}, true)")
  end
end
