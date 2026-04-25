# frozen_string_literal: true

class SeedBehaviorModelsNothingZero < ActiveRecord::Migration[8.2]
  def up
    tables = %i[
      app_contact_behavior_events
      app_contact_behavior_levels
      app_document_behavior_levels
      app_timeline_behavior_events
      app_timeline_behavior_levels
      com_document_behavior_levels
    ]

    safety_assured do
      tables.each do |table|
        next unless table_exists?(table)

        execute(<<~SQL.squish)
          INSERT INTO #{table} (id)
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
