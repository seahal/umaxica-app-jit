# frozen_string_literal: true

class EnsurePreferenceTimezoneOptions < ActiveRecord::Migration[8.2]
  def up
    timezone_ids = %w(Etc/UTC Asia/Tokyo)

    %w(app com org).each do |namespace|
      table_name = "#{namespace}_preference_timezone_options"

      safety_assured do
        values_sql = timezone_ids.map { |id| "('#{id}')" }.join(", ")

        execute(<<~SQL.squish)
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
    timezone_ids = %w(Etc/UTC Asia/Tokyo)
    ids_sql = timezone_ids.map { |id| "'#{id}'" }.join(", ")

    %w(app com org).each do |namespace|
      table_name = "#{namespace}_preference_timezone_options"

      safety_assured do
        execute(<<~SQL.squish)
          DELETE FROM #{table_name}
          WHERE id IN (#{ids_sql});
        SQL
      end
    end
  end
end
