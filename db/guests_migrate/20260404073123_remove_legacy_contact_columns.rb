# typed: false
# frozen_string_literal: true

# Migration to remove legacy OTP/token columns from contact tables
# These columns were used for the legacy guest verification flow which has been removed.
class RemoveLegacyContactColumns < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Remove legacy token columns from main contact tables
      remove_column_if_exists(:app_contacts, :token)
      remove_column_if_exists(:app_contacts, :token_digest)
      remove_column_if_exists(:app_contacts, :token_expires_at)
      remove_column_if_exists(:app_contacts, :token_viewed)

      remove_column_if_exists(:com_contacts, :token)
      remove_column_if_exists(:com_contacts, :token_digest)
      remove_column_if_exists(:com_contacts, :token_expires_at)
      remove_column_if_exists(:com_contacts, :token_viewed)

      remove_column_if_exists(:org_contacts, :token)
      remove_column_if_exists(:org_contacts, :token_digest)
      remove_column_if_exists(:org_contacts, :token_expires_at)
      remove_column_if_exists(:org_contacts, :token_viewed)

      # Remove legacy columns from email tables
      remove_email_legacy_columns(:app_contact_emails)
      remove_email_legacy_columns(:com_contact_emails)
      remove_email_legacy_columns(:org_contact_emails)

      # Remove legacy columns from telephone tables
      remove_telephone_legacy_columns(:app_contact_telephones)
      remove_telephone_legacy_columns(:com_contact_telephones)
      remove_telephone_legacy_columns(:org_contact_telephones)

      # Remove legacy columns from topic tables
      remove_topic_legacy_columns(:app_contact_topics)
      remove_topic_legacy_columns(:com_contact_topics)
      remove_topic_legacy_columns(:org_contact_topics)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "This migration removes legacy columns that should not be restored."
  end

  private

  def remove_column_if_exists(table, column)
    remove_column(table, column) if column_exists?(table, column)
  end

  def remove_email_legacy_columns(table)
    remove_column_if_exists(table, :token_digest)
    remove_column_if_exists(table, :token_expires_at)
    remove_column_if_exists(table, :token_viewed)
    remove_column_if_exists(table, :verifier_digest)
    remove_column_if_exists(table, :verifier_expires_at)
    remove_column_if_exists(table, :verifier_attempts_left)
    remove_column_if_exists(table, :activated)
    remove_column_if_exists(table, :deletable)
    remove_column_if_exists(table, :expires_at)
    remove_column_if_exists(table, :remaining_views)
    remove_column_if_exists(table, :hotp_counter)
    remove_column_if_exists(table, :hotp_secret)
  end

  def remove_telephone_legacy_columns(table)
    remove_column_if_exists(table, :token_digest)
    remove_column_if_exists(table, :token_expires_at)
    remove_column_if_exists(table, :token_viewed)
    remove_column_if_exists(table, :verifier_digest)
    remove_column_if_exists(table, :verifier_expires_at)
    remove_column_if_exists(table, :verifier_attempts_left)
    remove_column_if_exists(table, :activated)
    remove_column_if_exists(table, :deletable)
    remove_column_if_exists(table, :expires_at)
    remove_column_if_exists(table, :remaining_views)
  end

  def remove_topic_legacy_columns(table)
    remove_column_if_exists(table, :otp_digest)
    remove_column_if_exists(table, :otp_expires_at)
    remove_column_if_exists(table, :otp_attempts_left)
    remove_column_if_exists(table, :activated)
    remove_column_if_exists(table, :deletable)
    remove_column_if_exists(table, :expires_at)
    remove_column_if_exists(table, :remaining_views)
  end
end
