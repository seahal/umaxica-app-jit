# frozen_string_literal: true

class BackfillScavengerRegionalLookups < ActiveRecord::Migration[8.2]
  def change
    reversible do |dir|
      dir.up do
        safety_assured do
          execute(<<~SQL.squish)
            INSERT INTO scavenger_regional_statuses (id)
            VALUES (0), (1), (2), (3)
            ON CONFLICT (id) DO NOTHING
          SQL

          execute(<<~SQL.squish)
            INSERT INTO scavenger_regional_events (id)
            VALUES (0), (1), (2), (3), (4)
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      end

      dir.down do
        # No-op: keep historical lookup IDs for referential integrity.
      end
    end
  end
end
