# typed: false
# frozen_string_literal: true

class AddBlindIndexToStaffEmails < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column :staff_emails, :address_bidx, :string
    add_column :staff_emails, :address_digest, :string

    add_index :staff_emails, :address_bidx,
              unique: true,
              where: "address_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :staff_emails, :address_digest,
              unique: true,
              where: "address_digest IS NOT NULL",
              algorithm: :concurrently
  end
end
