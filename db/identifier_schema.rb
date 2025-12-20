# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_27_130019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "apple_auths", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "access_token"
    t.timestamptz "created_at", null: false
    t.string "email"
    t.timestamptz "expires_at"
    t.string "name"
    t.string "provider"
    t.text "refresh_token"
    t.string "uid"
    t.timestamptz "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_apple_auths_on_user_id"
  end

  create_table "google_auths", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "access_token"
    t.timestamptz "created_at", null: false
    t.string "email"
    t.timestamptz "expires_at"
    t.string "image_url"
    t.string "name"
    t.string "provider"
    t.text "raw_info"
    t.text "refresh_token"
    t.string "uid"
    t.timestamptz "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_google_auths_on_user_id"
  end

  create_table "staff_identity_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "description", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.bigint "staff_id", null: false
    t.timestamptz "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
  end

  create_table "user_identity_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "description", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.timestamptz "updated_at", null: false
    t.bigint "user_id", null: false
    t.uuid "webauthn_id", null: false
    t.index ["user_id"], name: "index_user_identity_passkeys_on_user_id"
  end

  create_table "staff_identity_emails", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "address"
    t.timestamptz "created_at", null: false
    t.bigint "staff_id"
    t.timestamptz "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_emails_on_staff_id"
  end

  create_table "staff_hmac_based_one_time_passwords", id: false, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.binary "hmac_based_one_time_password_id", null: false
    t.binary "staff_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "staff_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.text "public_key"
    t.integer "sign_count"
    t.uuid "staff_id", null: false
    t.string "transports"
    t.timestamptz "updated_at", null: false
    t.string "user_handle"
    t.index ["external_id"], name: "index_staff_passkeys_on_external_id"
    t.index ["staff_id"], name: "index_staff_passkeys_on_staff_id"
  end

  create_table "staff_recovery_codes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.bigint "staff_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staff_identity_telephones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "number"
    t.bigint "staff_id"
    t.timestamptz "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_telephones_on_staff_id"
  end

  create_table "staff_time_based_one_time_passwords", id: false, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.uuid "staff_id", null: false
    t.uuid "time_based_one_time_password_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "staffs", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.string "webauthn_id"
  end

  create_table "user_identity_social_apples", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "token"
    t.timestamptz "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_social_apples_on_user_id"
  end

  create_table "user_identity_emails", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "address"
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_emails_on_user_id"
  end

  create_table "user_identity_social_googles", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "token"
    t.timestamptz "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_social_googles_on_user_id"
  end

  create_table "user_identity_one_time_passwords", id: false, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.binary "hmac_based_one_time_password_id", null: false
    t.timestamptz "updated_at", null: false
    t.binary "user_id", null: false
  end

  create_table "user_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.text "public_key"
    t.integer "sign_count"
    t.string "transports"
    t.timestamptz "updated_at", null: false
    t.string "user_handle"
    t.uuid "user_id", null: false
    t.index ["external_id"], name: "index_user_passkeys_on_external_id"
    t.index ["user_id"], name: "index_user_passkeys_on_user_id"
  end

  create_table "user_recovery_codes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.timestamptz "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_user_recovery_codes_on_user_id"
  end

  create_table "user_identity_telephones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.string "number"
    t.timestamptz "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_telephones_on_user_id"
  end

  create_table "user_time_based_one_time_passwords", id: false, force: :cascade do |t|
    t.binary "time_based_one_time_password_id", null: false
    t.binary "user_id", null: false
  end

  create_table "users", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
    t.string "webauthn_id"
  end

  add_foreign_key "apple_auths", "users"
  add_foreign_key "google_auths", "users"
  add_foreign_key "staff_passkeys", "staffs"
  add_foreign_key "user_passkeys", "users"
end
