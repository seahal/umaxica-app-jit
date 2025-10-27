class AddVerificationFieldsToContacts < ActiveRecord::Migration[8.1]
  def change
    # Add email verification fields to corporate_site_contact_emails
    add_column :corporate_site_contact_emails, :verifier_digest, :string, limit: 255
    add_column :corporate_site_contact_emails, :verifier_expires_at, :timestamptz
    add_column :corporate_site_contact_emails, :verifier_attempts_left, :integer, limit: 2, default: 3, null: false

    # Add OTP verification fields to corporate_site_contact_telephones
    add_column :corporate_site_contact_telephones, :otp_digest, :string, limit: 255
    add_column :corporate_site_contact_telephones, :otp_expires_at, :timestamptz
    add_column :corporate_site_contact_telephones, :otp_attempts_left, :integer, limit: 2, default: 3, null: false

    # Add token digest to corporate_site_contacts (for final one-time token)
    add_column :corporate_site_contacts, :token_digest, :string, limit: 255
    add_column :corporate_site_contacts, :token_expires_at, :timestamptz
    add_column :corporate_site_contacts, :token_viewed, :boolean, default: false, null: false

    # Add indexes for performance
    add_index :corporate_site_contact_emails, :verifier_expires_at
    add_index :corporate_site_contact_telephones, :otp_expires_at
    add_index :corporate_site_contacts, :token_digest
    add_index :corporate_site_contacts, :token_expires_at
  end
end
