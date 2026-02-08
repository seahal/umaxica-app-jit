# frozen_string_literal: true

class SeedPreferenceAuditEventsAndLevels < ActiveRecord::Migration[8.2]
  PREFERENCE_EVENTS = %w(
    CREATE_NEW_PREFERENCE_TOKEN
    PREFERENCE_CREATED
    PREFERENCE_ACCESSED
    PREFERENCE_UPDATED
    PREFERENCE_DESTROYED
  ).freeze

  LEVELS = %w(NEYO INFO WARN ERROR).freeze

  def up
    seed_ids("app_preference_audit_events", PREFERENCE_EVENTS)
    seed_ids("org_preference_audit_events", PREFERENCE_EVENTS)
    seed_ids("com_preference_audit_events", PREFERENCE_EVENTS)

    seed_ids("app_preference_audit_levels", LEVELS)
    seed_ids("org_preference_audit_levels", LEVELS)
    seed_ids("com_preference_audit_levels", LEVELS)
  end

  def down
    # No-op: leave data in place
  end

  private

  def seed_ids(table_name, ids)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    safety_assured do
      ids.each do |id|
        if has_timestamps
          execute <<~SQL.squish
            INSERT INTO #{table_name} (id, created_at, updated_at)
            VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            ON CONFLICT (id) DO NOTHING
          SQL
        else
          execute <<~SQL.squish
            INSERT INTO #{table_name} (id)
            VALUES ('#{id}')
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      end
    end
  end
end
