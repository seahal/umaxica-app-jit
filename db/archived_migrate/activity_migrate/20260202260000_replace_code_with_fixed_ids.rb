# frozen_string_literal: true

class ReplaceCodeWithFixedIds < ActiveRecord::Migration[8.0]
  def up
    target_tables = {
      app_document_audit_events: {
        1 => "CREATED",
      },
      app_document_audit_levels: {
        1 => "NEYO",
      },
      app_preference_audit_events: {
        1 => "REFRESH_TOKEN_ROTATED",
        2 => "UPDATE_PREFERENCE_COOKIE",
        3 => "UPDATE_PREFERENCE_COLORTHEME",
        4 => "RESET_BY_USER_DECISION",
        5 => "UPDATE_PREFERENCE_TIMEZONE",
        6 => "UPDATE_PREFERENCE_REGION",
        7 => "UPDATE_PREFERENCE_LANGUAGE",
        8 => "CREATE_NEW_PREFERENCE_TOKEN",
      },
      app_preference_audit_levels: {
        1 => "INFO",
      },
      com_document_audit_events: {
        1 => "CREATED",
      },
      com_document_audit_levels: {
        1 => "NEYO",
      },
      com_preference_audit_events: {
        1 => "CREATE_NEW_PREFERENCE_TOKEN",
        2 => "REFRESH_TOKEN_ROTATED",
        3 => "UPDATE_PREFERENCE_COOKIE",
        4 => "UPDATE_PREFERENCE_LANGUAGE",
        5 => "UPDATE_PREFERENCE_TIMEZONE",
        6 => "RESET_BY_USER_DECISION",
        7 => "UPDATE_PREFERENCE_REGION",
        8 => "UPDATE_PREFERENCE_COLORTHEME",
      },
      com_preference_audit_levels: {
        1 => "INFO",
      },
      com_timeline_audit_events: {
        1 => "CREATED",
      },
      com_timeline_audit_levels: {
        1 => "NEYO",
      },
      org_document_audit_events: {
        1 => "CREATED",
      },
      org_document_audit_levels: {
        1 => "NEYO",
      },
      org_preference_audit_events: {
        1 => "CREATE_NEW_PREFERENCE_TOKEN",
        2 => "REFRESH_TOKEN_ROTATED",
        3 => "UPDATE_PREFERENCE_COOKIE",
        4 => "UPDATE_PREFERENCE_LANGUAGE",
        5 => "UPDATE_PREFERENCE_TIMEZONE",
        6 => "RESET_BY_USER_DECISION",
        7 => "UPDATE_PREFERENCE_REGION",
        8 => "UPDATE_PREFERENCE_COLORTHEME",
      },
      org_preference_audit_levels: {
        1 => "INFO",
      },
      staff_audit_events: {
        1 => "LOGIN_SUCCESS",
        2 => "AUTHORIZATION_FAILED",
        3 => "LOGGED_IN",
        4 => "LOGGED_OUT",
        5 => "LOGIN_FAILED",
        6 => "TOKEN_REFRESHED",
        7 => "NEYO",
      },
      staff_audit_levels: {
        1 => "NEYO",
      },
      user_audit_events: {
        1 => "ACCOUNT_RECOVERED",
        2 => "ACCOUNT_WITHDRAWN",
        3 => "AUTHORIZATION_FAILED",
        4 => "LOGGED_IN",
        5 => "LOGGED_OUT",
        6 => "LOGIN_FAILED",
        7 => "LOGIN_SUCCESS",
        8 => "LOGOUT",
        9 => "NEYO",
        10 => "NON_EXISTENT_EVENT",
        11 => "PASSKEY_REGISTERED",
        12 => "PASSKEY_REMOVED",
        13 => "RECOVERY_CODES_GENERATED",
        14 => "RECOVERY_CODE_USED",
        15 => "SIGNED_UP_WITH_APPLE",
        16 => "SIGNED_UP_WITH_EMAIL",
        17 => "SIGNED_UP_WITH_GOOGLE",
        18 => "SIGNED_UP_WITH_TELEPHONE",
        19 => "TOKEN_REFRESHED",
        20 => "TOTP_DISABLED",
        21 => "TOTP_ENABLED",
      },
      user_audit_levels: {
        1 => "DEBUG",
        2 => "ERROR",
        3 => "INFO",
        4 => "NEYO",
        5 => "WARN",
      },
      app_contact_audit_events: {
        1 => "NEYO",
        2 => "CREATED",
        3 => "UPDATED",
        4 => "DELETED",
      },
      app_contact_audit_levels: {
        1 => "NEYO",
        2 => "DEBUG",
        3 => "INFO",
        4 => "WARN",
        5 => "ERROR",
      },
      app_timeline_audit_events: {
        1 => "NEYO",
        2 => "CREATED",
        3 => "UPDATED",
        4 => "DELETED",
      },
      app_timeline_audit_levels: {
        1 => "NEYO",
        2 => "DEBUG",
        3 => "INFO",
        4 => "WARN",
        5 => "ERROR",
      },
      com_contact_audit_events: {
        1 => "NEYO",
        2 => "CREATED",
        3 => "UPDATED",
        4 => "DELETED",
      },
      com_contact_audit_levels: {
        1 => "NEYO",
        2 => "DEBUG",
        3 => "INFO",
        4 => "WARN",
        5 => "ERROR",
      },
      org_contact_audit_events: {
        1 => "NEYO",
        2 => "CREATED",
        3 => "UPDATED",
        4 => "DELETED",
      },
      org_contact_audit_levels: {
        1 => "NEYO",
        2 => "DEBUG",
        3 => "INFO",
        4 => "WARN",
        5 => "ERROR",
      },
      org_timeline_audit_events: {
        1 => "NEYO",
        2 => "CREATED",
        3 => "UPDATED",
        4 => "DELETED",
      },
      org_timeline_audit_levels: {
        1 => "NEYO",
        2 => "DEBUG",
        3 => "INFO",
        4 => "WARN",
        5 => "ERROR",
      },
    }

    safety_assured do
      target_tables.each do |table_name, mapping|
        # Ensure table exists
        unless table_exists?(table_name)
          create_table(table_name, id: :bigint) do |t|
            t.citext(:code, null: false, index: { unique: true })
          end
        end

        # 1. Truncate table and cascade to clear references
        execute("TRUNCATE TABLE #{table_name} RESTART IDENTITY CASCADE")

        # 2. Insert fixed IDs
        mapping.each do |id, code|
          execute("INSERT INTO #{table_name} (id, code) VALUES (#{id}, '#{code}')")
        end

        # 3. Update sequence
        max_id = mapping.keys.max
        execute("SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), #{max_id})")

        # 4. Remove code column and index
        remove_column(table_name, :code)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
