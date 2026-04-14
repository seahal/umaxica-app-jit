# typed: false
# frozen_string_literal: true

class AddBlindIndexToContactTelephones < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    # AppContactTelephone
    add_column :app_contact_telephones, :telephone_number_bidx, :string
    add_column :app_contact_telephones, :telephone_number_digest, :string
    add_index :app_contact_telephones, :telephone_number_bidx,
              unique: true,
              where: "telephone_number_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :app_contact_telephones, :telephone_number_digest,
              unique: true,
              where: "telephone_number_digest IS NOT NULL",
              algorithm: :concurrently

    # ComContactTelephone
    add_column :com_contact_telephones, :telephone_number_bidx, :string
    add_column :com_contact_telephones, :telephone_number_digest, :string
    add_index :com_contact_telephones, :telephone_number_bidx,
              unique: true,
              where: "telephone_number_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :com_contact_telephones, :telephone_number_digest,
              unique: true,
              where: "telephone_number_digest IS NOT NULL",
              algorithm: :concurrently

    # OrgContactTelephone
    add_column :org_contact_telephones, :telephone_number_bidx, :string
    add_column :org_contact_telephones, :telephone_number_digest, :string
    add_index :org_contact_telephones, :telephone_number_bidx,
              unique: true,
              where: "telephone_number_bidx IS NOT NULL",
              algorithm: :concurrently
    add_index :org_contact_telephones, :telephone_number_digest,
              unique: true,
              where: "telephone_number_digest IS NOT NULL",
              algorithm: :concurrently
  end
end
