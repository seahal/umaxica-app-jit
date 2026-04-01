# frozen_string_literal: true

class RenameOperatorIdentityTables < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Staff Identity tables
      safe_rename(:staff_identity_audit_events, :staff_audit_events)
      safe_rename(:staff_identity_audit_levels, :staff_audit_levels)
      safe_rename(:staff_identity_audits, :staff_audits)
      safe_rename(:staff_identity_email_statuses, :staff_email_statuses)
      safe_rename(:staff_identity_emails, :staff_emails)
      safe_rename(:staff_identity_passkey_statuses, :staff_passkey_statuses)
      safe_rename(:staff_identity_passkeys, :staff_passkeys)
      safe_rename(:staff_identity_secret_statuses, :staff_secret_statuses)
      safe_rename(:staff_identity_secrets, :staff_secrets)
      safe_rename(:staff_identity_statuses, :staff_statuses)
      safe_rename(:staff_identity_telephone_statuses, :staff_telephone_statuses)
      safe_rename(:staff_identity_telephones, :staff_telephones)

      # Operator Identity tables
      safe_rename(:admin_identity_statuses, :operator_statuses)
    end
  end

  def down
    safety_assured do
      rename_table(:operator_statuses, :admin_identity_statuses)
      rename_table(:staff_telephones, :staff_identity_telephones)
      rename_table(:staff_telephone_statuses, :staff_identity_telephone_statuses)
      rename_table(:staff_statuses, :staff_identity_statuses)
      rename_table(:staff_secrets, :staff_identity_secrets)
      rename_table(:staff_secret_statuses, :staff_identity_secret_statuses)
      rename_table(:staff_passkeys, :staff_identity_passkeys)
      rename_table(:staff_passkey_statuses, :staff_identity_passkey_statuses)
      rename_table(:staff_emails, :staff_identity_emails)
      rename_table(:staff_email_statuses, :staff_identity_email_statuses)
      rename_table(:staff_audits, :staff_identity_audits)
      rename_table(:staff_audit_levels, :staff_identity_audit_levels)
      rename_table(:staff_audit_events, :staff_identity_audit_events)
    end
  end

  private

  def safe_rename(old_name, new_name)
    return unless connection.table_exists?(old_name)
    return if connection.table_exists?(new_name)

    connection.execute("ALTER TABLE #{old_name} RENAME TO #{new_name}")
  end
end
