# frozen_string_literal: true

class EnsureNothingAppDocumentBehaviorEvent < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute <<~SQL.squish
        INSERT INTO app_document_behavior_events (id)
        VALUES (0)
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    # no-op: keep seeded reference data
  end
end
