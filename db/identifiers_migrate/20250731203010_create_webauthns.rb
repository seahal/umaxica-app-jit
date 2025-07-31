class CreateWebauthns < ActiveRecord::Migration[8.0]
  def change
    create_table :webauthns, id: :uuid do |t|
      t.binary :user_id, null: false
      t.binary :webauthn_id, null: false
      t.text :public_key, null: false
      t.integer :sign_count, default: 0, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :webauthns, :user_id
    add_index :webauthns, :webauthn_id, unique: true
  end
end
