# typed: false
# frozen_string_literal: true

class CreateAuthorizationCodes < ActiveRecord::Migration[8.2]
  def change
    create_table :authorization_codes do |t|
      t.string :code, limit: 64, null: false
      t.bigint :user_id, null: false
      t.string :client_id, limit: 64, null: false
      t.text :redirect_uri, null: false
      t.string :code_challenge, null: false
      t.string :code_challenge_method, limit: 8, null: false, default: "S256"
      t.string :scope
      t.string :state
      t.string :nonce
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :consumed_at

      t.timestamps
    end

    add_index :authorization_codes, :code, unique: true
    add_index :authorization_codes, :user_id
    add_index :authorization_codes, :expires_at
  end
end
