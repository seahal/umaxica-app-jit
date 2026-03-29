# frozen_string_literal: true

class SeedUserAndJwtOccurrenceStatusNothingZero < ActiveRecord::Migration[8.2]
  TABLES = %i[
    user_occurrence_statuses
    jwt_occurrence_statuses
  ].freeze

  def up
    safety_assured do
      TABLES.each do |table_name|
        next unless table_exists?(table_name)

        execute(<<~SQL.squish)
          INSERT INTO #{table_name} (id)
          VALUES (0)
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end

  def down
    # Keep shared reference data in place once introduced.
  end
end
