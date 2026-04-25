# frozen_string_literal: true

class AddPreferenceRegionAndColorthemeEvents < ActiveRecord::Migration[8.0]
  def up
    %w(app com org).each do |namespace|
      safety_assured do
        execute(<<~SQL.squish)
          INSERT INTO #{namespace}_preference_audit_events (id, created_at, updated_at)
          VALUES
            ('UPDATE_PREFERENCE_REGION', NOW(), NOW()),
            ('UPDATE_PREFERENCE_COLORTHEME', NOW(), NOW())
          ON CONFLICT (id) DO NOTHING;
        SQL
      end
    end
  end

  def down
    %w(app com org).each do |namespace|
      safety_assured do
        execute(<<~SQL.squish)
          DELETE FROM #{namespace}_preference_audit_events
          WHERE id IN ('UPDATE_PREFERENCE_REGION', 'UPDATE_PREFERENCE_COLORTHEME');
        SQL
      end
    end
  end
end
