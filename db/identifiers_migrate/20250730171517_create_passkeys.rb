class CreatePasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :passkeys, id: :uuid do |t|
      t.bytea :user_id, null: false
      t.bytea :webauthn_id, null: false
      t.text :public_key, null: false
      t.integer :sign_count, default: 0, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
