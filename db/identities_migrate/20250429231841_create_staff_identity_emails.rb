# frozen_string_literal: true

class CreateStaffIdentityEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :staff_identity_emails, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :staff, type: :uuid, foreign_key: true
      t.string :address
      t.timestamps
    end
  end
end
