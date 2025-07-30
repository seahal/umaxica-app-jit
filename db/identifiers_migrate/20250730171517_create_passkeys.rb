class CreatePasskeys < ActiveRecord::Migration[8.0]
  def change
    create_table :passkeys, id: :uuid do |t|
      t.bytea :user_id, null: false #, foreign_key: true
      t.text :public_key
      t.string :nickname
      t.integer :sign_count
      t.integer :authenticator_type
      t.boolean :active

      t.timestamps
    end
  end
end
