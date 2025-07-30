class CreatePasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :passkeys, id: :uuid do |t|
      t.bytea :user_id, null: false
      t.bytea :credential_id, null: false
      t.bytea :public_key, null: false
      t.bigint :sign_count, default: 0, null: false
      t.bytea :user_handle, null: false
      t.string :description, null: false
      t.boolean :active, default: true, null: false
      t.timestamp :last_used_at

      t.timestamps
    end

    add_index :passkeys, :credential_id, unique: true
    add_index :passkeys, [:user_id, :active]
    add_index :passkeys, [:user_id, :nickname]
    add_foreign_key :passkeys, :users, column: :user_id
  end
end
