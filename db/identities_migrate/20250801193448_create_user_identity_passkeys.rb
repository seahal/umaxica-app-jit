# frozen_string_literal: true

class CreateUserIdentityPasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :user_identity_passkeys, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.uuid :webauthn_id, null: false
      t.text :public_key, null: false
      t.string :description, null: false
      t.bigint :sign_count, null: false, default: 0
      t.uuid :external_id, null: false
      t.timestamps
    end

    add_index :user_identity_passkeys, :webauthn_id, unique: true
  end
end
