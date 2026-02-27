# frozen_string_literal: true

class CreatePasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :passkeys do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :credential_id, null: false
      t.text :public_key, null: false
      t.integer :sign_count, null: false, default: 0

      t.timestamps
    end
    add_index :passkeys, :credential_id, unique: true
  end
end
