# frozen_string_literal: true

class SeedIdentityAuditEventsAndLevels < ActiveRecord::Migration[8.2]
  USER_EVENTS = %w(
    LOGIN_SUCCESS
    LOGIN_FAILURE
    LOGGED_IN
    LOGGED_OUT
    LOGIN_FAILED
    TOKEN_REFRESHED
    SIGNED_UP_WITH_EMAIL
    SIGNED_UP_WITH_TELEPHONE
    SIGNED_UP_WITH_APPLE
    AUTHORIZATION_FAILED
  ).freeze

  STAFF_EVENTS = %w(
    LOGIN_SUCCESS
    LOGIN_FAILURE
    LOGGED_IN
    LOGGED_OUT
    LOGIN_FAILED
    AUTHORIZATION_FAILED
  ).freeze

  LEVELS = %w(NONE INFO WARN ERROR).freeze

  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end

  private

  def seed_ids(table_name, ids)
    # return unless table_exists?(table_name)

    # Check if table has timestamp columns
    has_timestamps = column_exists?(table_name, :created_at)

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
