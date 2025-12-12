class ConsolidateOneTimePassword < ActiveRecord::Migration[8.2]
  def change
    # Add columns from HmacBasedOneTimePassword to UserIdentityOneTimePassword
    change_table :user_identity_one_time_passwords, bulk: true do |t|
      t.string :private_key, limit: 1024, null: true
      t.datetime :last_otp_at, null: true
    end

    # Remove foreign key reference
    reversible do |dir|
      dir.up do
        remove_column :user_identity_one_time_passwords, :hmac_based_one_time_password_id, :binary
      end
      dir.down do
        add_column :user_identity_one_time_passwords, :hmac_based_one_time_password_id, :binary, null: false, default: "\x00"
      end
    end
  end
end
