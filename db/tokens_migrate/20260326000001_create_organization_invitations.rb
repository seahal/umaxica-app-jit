# typed: false
# frozen_string_literal: true

class CreateOrganizationInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_invitations do |t|
      t.string :code, null: false, limit: 32
      t.string :email, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.bigint :organization_id, null: false
      t.bigint :invited_by_id, null: false
      t.bigint :role_id, null: false, default: 0

      t.timestamps
    end

    add_index :organization_invitations, :code, unique: true
    add_index :organization_invitations, :organization_id
    add_index :organization_invitations, :invited_by_id
    add_index :organization_invitations, :email
  end
end
