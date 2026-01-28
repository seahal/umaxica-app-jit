# frozen_string_literal: true

# Adds otp_nonce column for latest-only OTP verification
# This ensures only the most recent OTP succeeds, even under concurrency
class AddOtpNonceToIdentityTables < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    # Add otp_nonce to user_emails
    add_column :user_emails, :otp_nonce, :bigint, default: 0, null: false
    add_index :user_emails, :otp_nonce, algorithm: :concurrently

    # Add otp_nonce to user_telephones
    add_column :user_telephones, :otp_nonce, :bigint, default: 0, null: false
    add_index :user_telephones, :otp_nonce, algorithm: :concurrently
  end
end
