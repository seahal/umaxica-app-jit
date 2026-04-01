# frozen_string_literal: true

class RenamePrincipalIdentityTables < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # User Identity tables
      safe_rename(:user_identity_audit_events, :user_audit_events)
      safe_rename(:user_identity_audit_levels, :user_audit_levels)
      safe_rename(:user_identity_audits, :user_audits)
      safe_rename(:user_identity_email_statuses, :user_email_statuses)
      safe_rename(:user_identity_emails, :user_emails)
      safe_rename(:user_identity_one_time_password_statuses, :user_one_time_password_statuses)
      safe_rename(:user_identity_one_time_passwords, :user_one_time_passwords)
      safe_rename(:user_identity_passkey_statuses, :user_passkey_statuses)
      safe_rename(:user_identity_passkeys, :user_passkeys)
      safe_rename(:user_identity_secret_statuses, :user_secret_statuses)
      safe_rename(:user_identity_secrets, :user_secrets)
      safe_rename(:user_identity_social_apple_statuses, :user_social_apple_statuses)
      safe_rename(:user_identity_social_apples, :user_social_apples)
      safe_rename(:user_identity_social_google_statuses, :user_social_google_statuses)
      safe_rename(:user_identity_social_googles, :user_social_googles)
      safe_rename(:user_identity_statuses, :user_statuses)
      safe_rename(:user_identity_telephone_statuses, :user_telephone_statuses)
      safe_rename(:user_identity_telephones, :user_telephones)

      # Client Identity tables
      safe_rename(:client_identity_statuses, :client_statuses)
    end
  end

  def down
    safety_assured do
      rename_table(:client_statuses, :client_identity_statuses)
      rename_table(:user_telephones, :user_identity_telephones)
      rename_table(:user_telephone_statuses, :user_identity_telephone_statuses)
      rename_table(:user_statuses, :user_identity_statuses)
      rename_table(:user_social_googles, :user_identity_social_googles)
      rename_table(:user_social_google_statuses, :user_identity_social_google_statuses)
      rename_table(:user_social_apples, :user_identity_social_apples)
      rename_table(:user_social_apple_statuses, :user_identity_social_apple_statuses)
      rename_table(:user_secrets, :user_identity_secrets)
      rename_table(:user_secret_statuses, :user_identity_secret_statuses)
      rename_table(:user_passkeys, :user_identity_passkeys)
      rename_table(:user_passkey_statuses, :user_identity_passkey_statuses)
      rename_table(:user_one_time_passwords, :user_identity_one_time_passwords)
      rename_table(:user_one_time_password_statuses, :user_identity_one_time_password_statuses)
      rename_table(:user_emails, :user_identity_emails)
      rename_table(:user_email_statuses, :user_identity_email_statuses)
      rename_table(:user_audits, :user_identity_audits)
      rename_table(:user_audit_levels, :user_identity_audit_levels)
      rename_table(:user_audit_events, :user_identity_audit_events)
    end
  end

  private

  def safe_rename(old_name, new_name)
    return unless connection.table_exists?(old_name)
    return if connection.table_exists?(new_name)

    connection.execute("ALTER TABLE #{old_name} RENAME TO #{new_name}")
  end
end
