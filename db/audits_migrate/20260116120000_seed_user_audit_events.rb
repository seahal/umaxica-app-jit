# frozen_string_literal: true

class SeedUserAuditEvents < ActiveRecord::Migration[8.2]
  EVENT_IDS = %w[
    NEYO
    LOGIN_SUCCESS
    LOGIN_FAILED
    LOGOUT
    LOGGED_IN
    LOGGED_OUT
    SIGNED_UP_WITH_EMAIL
    SIGNED_UP_WITH_TELEPHONE
    SIGNED_UP_WITH_GOOGLE
    SIGNED_UP_WITH_APPLE
    TOKEN_REFRESHED
    ACCOUNT_WITHDRAWN
    ACCOUNT_RECOVERED
    PASSKEY_REGISTERED
    PASSKEY_REMOVED
    TOTP_ENABLED
    TOTP_DISABLED
    RECOVERY_CODE_USED
    RECOVERY_CODES_GENERATED
    AUTHORIZATION_FAILED
    NON_EXISTENT_EVENT
  ].freeze

  def up
    return unless table_exists?(:user_audit_events)

    EVENT_IDS.each do |event_id|
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
