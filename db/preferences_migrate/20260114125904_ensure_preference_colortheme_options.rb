# frozen_string_literal: true

class EnsurePreferenceColorthemeOptions < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      colortheme_ids = %w[light dark system]

      %w[app com org].each do |namespace|
        table_name = "#{namespace}_preference_colortheme_options"

        values_sql = colortheme_ids.map { |id| "('#{id}')" }.join(", ")

        execute <<~SQL.squish
          WITH max_pos AS (
            SELECT COALESCE(MAX(position), 0) AS max_pos FROM #{table_name}
          ),
          rows AS (
            SELECT v.id,
                   (SELECT max_pos FROM max_pos) + row_number() OVER () AS position
            FROM (VALUES #{values_sql}) AS v(id)
            WHERE NOT EXISTS (SELECT 1 FROM #{table_name} t WHERE t.id = v.id)
          )
          INSERT INTO #{table_name} (id, position, created_at, updated_at)
          SELECT id, position, NOW(), NOW() FROM rows;
        SQL
      end
    end
  end

  def down
    colortheme_ids = %w[light dark system]
    ids_sql = colortheme_ids.map { |id| "'#{id}'" }.join(", ")

    %w[app com org].each do |namespace|
      table_name = "#{namespace}_preference_colortheme_options"

      safety_assured do
        execute <<~SQL.squish
          DELETE FROM #{table_name}
          WHERE id IN (#{ids_sql});
        SQL
      end
    end
  end
end
