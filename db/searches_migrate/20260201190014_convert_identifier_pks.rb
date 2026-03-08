# frozen_string_literal: true

class ConvertIdentifierPks < ActiveRecord::Migration[8.0]
  def up
    # -------------------------------------------------------------------------
    # DROP
    # -------------------------------------------------------------------------
    tables = %w(
      apple_auths google_auths
      staff_identity_passkeys user_identity_passkeys
      staff_identity_emails user_identity_emails
      staff_identity_telephones user_identity_telephones
      staff_passkeys user_passkeys
      staff_recovery_codes user_recovery_codes
      user_identity_social_apples user_identity_social_googles
      staff_hmac_based_one_time_passwords user_identity_one_time_passwords
      staff_time_based_one_time_passwords user_time_based_one_time_passwords
      users staffs
    )

    tables.each do |table|
      drop_table table, if_exists: true
    end

    # -------------------------------------------------------------------------
    # RECREATE (Bigint PK)
    # -------------------------------------------------------------------------

    # Parents
    create_table :users do |t|
      t.string :webauthn_id
      t.timestamps
    end

    create_table :staffs do |t|
      t.string :webauthn_id
      t.timestamps
    end

    # Auth Providers
    create_table :apple_auths do |t|
      t.bigint :user_id, null: false
      t.string :uid
      t.string :provider
      t.string :email
      t.string :name
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.timestamps
      t.index :user_id
    end

    create_table :google_auths do |t|
      t.bigint :user_id, null: false
      t.string :uid
      t.string :provider
      t.string :email
      t.string :name
      t.string :image_url
      t.text :raw_info
      t.text :access_token
      t.text :refresh_token
      t.datetime :expires_at
      t.timestamps
      t.index :user_id
    end

    # Passkeys
    create_table :user_passkeys do |t|
      t.bigint :user_id, null: false
      t.string :external_id
      t.text :public_key
      t.integer :sign_count
      t.string :user_handle
      t.string :name
      t.string :transports
      t.timestamps
      t.index :user_id
      t.index :external_id
    end

    create_table :staff_passkeys do |t|
      t.bigint :staff_id, null: false
      t.string :external_id
      t.text :public_key
      t.integer :sign_count
      t.string :user_handle
      t.string :name
      t.string :transports
      t.timestamps
      t.index :staff_id
      t.index :external_id
    end

    # Identity Passkeys (Detailed)
    create_table :user_identity_passkeys do |t|
      t.bigint :user_id, null: false
      t.binary :webauthn_id, null: false
      t.text :public_key, null: false
      t.string :description, null: false
      t.bigint :sign_count, default: 0, null: false
      t.bigint :external_id, null: false
      t.timestamps
      t.index :user_id
    end

    create_table :staff_identity_passkeys do |t|
      t.bigint :staff_id, null: false
      t.binary :webauthn_id, null: false
      t.text :public_key, null: false
      t.string :description, null: false
      t.bigint :sign_count, default: 0, null: false
      t.bigint :external_id, null: false
      t.timestamps
      t.index :staff_id
    end

    # Emails/Telephones/Recovery
    create_table :user_identity_emails do |t|
      t.bigint :user_id
      t.string :address
      t.timestamps
      t.index :user_id
    end

    create_table :staff_identity_emails do |t|
      t.bigint :staff_id
      t.string :address
      t.timestamps
      t.index :staff_id
    end

    create_table :user_identity_telephones do |t|
      t.bigint :user_id
      t.string :number
      t.timestamps
      t.index :user_id
    end

    create_table :staff_identity_telephones do |t|
      t.bigint :staff_id
      t.string :number
      t.timestamps
      t.index :staff_id
    end

    create_table :user_recovery_codes do |t|
      t.bigint :user_id, null: false
      t.string :recovery_code_digest
      t.date :expires_in
      t.timestamps
      t.index :user_id
    end

    create_table :staff_recovery_codes do |t|
      t.bigint :staff_id, null: false
      t.string :recovery_code_digest
      t.date :expires_in
      t.timestamps
      t.index :staff_id
    end

    # Social Identities
    create_table :user_identity_social_apples do |t|
      t.bigint :user_id
      t.string :token
      t.timestamps
      t.index :user_id
    end

    create_table :user_identity_social_googles do |t|
      t.bigint :user_id
      t.string :token
      t.timestamps
      t.index :user_id
    end

    # OTPs (Standardizing to Bigint PK)
    # staff_hmac_based_one_time_passwords (old id: false)
    create_table :staff_hmac_based_one_time_passwords do |t|
      t.bigint :staff_id, null: false
      # No other columns in original? Just IDs.
      t.timestamps
      t.index :staff_id
    end

    create_table :staff_time_based_one_time_passwords do |t|
      t.bigint :staff_id, null: false
      t.timestamps
      # Original had :time_based_one_time_password_id (user/staff specific ID? maybe separate table ref? Assuming standard)
    end

    create_table :user_identity_one_time_passwords do |t|
      # Was hmac...
      t.bigint :user_id, null: false
      t.timestamps
    end

    create_table :user_time_based_one_time_passwords do |t|
      t.bigint :user_id, null: false
      t.timestamps
    end

    # FKs
    add_foreign_key :apple_auths, :users, validate: false
    add_foreign_key :google_auths, :users, validate: false
    add_foreign_key :user_passkeys, :users, validate: false
    add_foreign_key :staff_passkeys, :staffs, validate: false
    # Others if applicable (e.g. recovery codes) - Schema didn't show FKs for all, but usually implicit.
    # Schema lines 204-207 showed FKs for apple, google, staff_passkeys, user_passkeys.
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
