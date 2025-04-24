class CreateHmacBasedOneTimePasswords < ActiveRecord::Migration[8.0]
  def change
    create_table :hmac_based_one_time_passwords, id: :binary do |t|
      t.string :private_key, null: false, limit: 1024
      t.datetime :last_otp_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end
  end
end
