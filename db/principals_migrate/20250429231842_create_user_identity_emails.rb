# frozen_string_literal: true

class CreateUserIdentityEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :user_identity_emails, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.string :address
      t.timestamps
    end
  end
end
