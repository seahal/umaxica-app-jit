class ChangeAllDatetimeToTimestamptzInIdentifier < ActiveRecord::Migration[8.1]
  def up
    # apple_auths
    change_table :apple_auths, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
      t.change :expires_at, :timestamptz
    end

    # google_auths
    change_table :google_auths, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
      t.change :expires_at, :timestamptz
    end

    # passkey_for_staffs
    change_table :passkey_for_staffs, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # passkey_for_users
    change_table :passkey_for_users, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_emails
    change_table :staff_emails, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_hmac_based_one_time_passwords
    change_table :staff_hmac_based_one_time_passwords, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_passkeys
    change_table :staff_passkeys, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_recovery_codes
    change_table :staff_recovery_codes, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_telephones
    change_table :staff_telephones, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_time_based_one_time_passwords
    change_table :staff_time_based_one_time_passwords, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staffs
    change_table :staffs, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_apple_auths
    change_table :user_apple_auths, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_emails
    change_table :user_emails, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_google_auths
    change_table :user_google_auths, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_hmac_based_one_time_passwords
    change_table :user_hmac_based_one_time_passwords, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_passkeys
    change_table :user_passkeys, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_recovery_codes
    change_table :user_recovery_codes, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # user_telephones
    change_table :user_telephones, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # users
    change_table :users, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end
  end

  def down
    # Rollback to datetime
    # apple_auths
    change_table :apple_auths, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
      t.change :expires_at, :datetime
    end

    # google_auths
    change_table :google_auths, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
      t.change :expires_at, :datetime
    end

    # passkey_for_staffs
    change_table :passkey_for_staffs, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # passkey_for_users
    change_table :passkey_for_users, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_emails
    change_table :staff_emails, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_hmac_based_one_time_passwords
    change_table :staff_hmac_based_one_time_passwords, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_passkeys
    change_table :staff_passkeys, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_recovery_codes
    change_table :staff_recovery_codes, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_telephones
    change_table :staff_telephones, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_time_based_one_time_passwords
    change_table :staff_time_based_one_time_passwords, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staffs
    change_table :staffs, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_apple_auths
    change_table :user_apple_auths, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_emails
    change_table :user_emails, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_google_auths
    change_table :user_google_auths, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_hmac_based_one_time_passwords
    change_table :user_hmac_based_one_time_passwords, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_passkeys
    change_table :user_passkeys, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_recovery_codes
    change_table :user_recovery_codes, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # user_telephones
    change_table :user_telephones, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # users
    change_table :users, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end
  end
end
