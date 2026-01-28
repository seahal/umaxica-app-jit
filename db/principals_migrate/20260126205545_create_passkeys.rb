# frozen_string_literal: true

class CreatePasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :passkeys, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :credential_id, null: false
      t.text :public_key, null: false
      t.integer :sign_count, null: false, default: 0

      t.timestamps
    end
    add_index :passkeys, :credential_id, unique: true
  end
end
