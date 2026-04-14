# typed: false
# frozen_string_literal: true

class AddBlindIndexToContactEmails < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # AppContactEmail
    add_column :app_contact_emails, :email_address_bidx, :string
    add_column :app_contact_emails, :email_address_digest, :string
    add_index :app_contact_emails, :email_address_bidx,
              unique: true,
              where: "email_address_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :app_contact_emails, :email_address_digest,
              unique: true,
              where: "email_address_digest IS NOT NULL",
              algorithm: :concurrently

    # ComContactEmail
    add_column :com_contact_emails, :email_address_bidx, :string
    add_column :com_contact_emails, :email_address_digest, :string
    add_index :com_contact_emails, :email_address_bidx,
              unique: true,
              where: "email_address_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :com_contact_emails, :email_address_digest,
              unique: true,
              where: "email_address_digest IS NOT NULL",
              algorithm: :concurrently

    # OrgContactEmail
    add_column :org_contact_emails, :email_address_bidx, :string
    add_column :org_contact_emails, :email_address_digest, :string
    add_index :org_contact_emails, :email_address_bidx,
              unique: true,
              where: "email_address_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :org_contact_emails, :email_address_digest,
              unique: true,
              where: "email_address_digest IS NOT NULL",
              algorithm: :concurrently
  end
end
