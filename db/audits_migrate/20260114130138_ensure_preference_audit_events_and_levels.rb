# frozen_string_literal: true

class EnsurePreferenceAuditEventsAndLevels < ActiveRecord::Migration[8.2]
  EVENTS = %w(
    CREATE_NEW_PREFERENCE_TOKEN
    PREFERENCE_CREATED
    PREFERENCE_ACCESSED
    PREFERENCE_UPDATED
    PREFERENCE_DESTROYED
    UPDATE_PREFERENCE_COOKIE
    UPDATE_PREFERENCE_LANGUAGE
    UPDATE_PREFERENCE_TIMEZONE
    UPDATE_PREFERENCE_REGION
    UPDATE_PREFERENCE_COLORTHEME
    RESET_BY_USER_DECISION
  ).freeze

  LEVELS = %w(NEYO INFO WARN ERROR).freeze

  def up
    %w(app com org).each do |namespace|
      seed_ids("#{namespace}_preference_audit_events", EVENTS)
      seed_ids("#{namespace}_preference_audit_levels", LEVELS)
    end
  end

  def down
    # No-op: leave reference data in place.
  end

  private

  def seed_ids(table_name, ids)
    return unless table_exists?(table_name)

    safety_assured do
      ids.each do |id|
        execute <<~SQL.squish
          INSERT INTO #{table_name} (id, created_at, updated_at)
          VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end
end
