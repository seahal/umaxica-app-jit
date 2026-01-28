# frozen_string_literal: true

class SeedUserIdentitySecretAuditEvents < ActiveRecord::Migration[8.2]
  SECRET_EVENT_IDS = %w[
    USER_IDENTITY_SECRET_CREATE
    USER_IDENTITY_SECRET_DELETE
  ].freeze

  def up
    return unless table_exists?(:user_audit_events)

    SECRET_EVENT_IDS.each do |event_id|
      insert_event(event_id)
    end
  end

  def down
    # No-op: keep seeded reference data in place.
  end

  private

    def insert_event(event_id)
      if column_exists?(:user_audit_events, :created_at)
        safety_assured do
          execute <<~SQL.squish
            INSERT INTO user_audit_events (id, created_at, updated_at)
            VALUES ('#{event_id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      else
        safety_assured do
          execute <<~SQL.squish
            INSERT INTO user_audit_events (id)
            VALUES ('#{event_id}')
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      end
    end
end
