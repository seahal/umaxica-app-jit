class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    # FIXME: need hashed partition.
    create_table :users, id: :uuid do |t|
      t.string :encrypted_password, limit: 512, default: nil
      t.string :display_name, limit: 32, default: nil

      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.timestamps
    end
  end
end
