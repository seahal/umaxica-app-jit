# frozen_string_literal: true

class SeedUserAuditLevels < ActiveRecord::Migration[8.2]
  LEVEL_IDS = %w(
    NEYO
    INFO
    DEBUG
    WARN
    ERROR
  ).freeze

  def up
    return unless table_exists?(:user_audit_levels)

    LEVEL_IDS.each do |level_id|
      insert_level(level_id)
    end
  end

  def down
    # No-op: keep seeded reference data in place.
  end

  private

  def insert_level(level_id)
    if column_exists?(:user_audit_levels, :created_at)
      safety_assured do
        execute(<<~SQL.squish)
          INSERT INTO user_audit_levels (id, created_at, updated_at)
          VALUES ('#{level_id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    else
      safety_assured do
        execute(<<~SQL.squish)
          INSERT INTO user_audit_levels (id)
          VALUES ('#{level_id}')
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end
end
