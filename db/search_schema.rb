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

ActiveRecord::Schema[8.2].define(version: 2026_02_01_190014) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "apple_auths", force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.string "name"
    t.string "provider"
    t.text "refresh_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_apple_auths_on_user_id"
  end

  create_table "google_auths", force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.string "image_url"
    t.string "name"
    t.string "provider"
    t.text "raw_info"
    t.text "refresh_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_google_auths_on_user_id"
  end

  create_table "staff_hmac_based_one_time_passwords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_hmac_based_one_time_passwords_on_staff_id"
  end

  create_table "staff_identity_emails", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.bigint "staff_id"
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_emails_on_staff_id"
  end

  create_table "staff_identity_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.bigint "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
  end

  create_table "staff_identity_telephones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "number"
    t.bigint "staff_id"
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_telephones_on_staff_id"
  end

  create_table "staff_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.text "public_key"
    t.integer "sign_count"
    t.bigint "staff_id", null: false
    t.string "transports"
    t.datetime "updated_at", null: false
    t.string "user_handle"
    t.index ["external_id"], name: "index_staff_passkeys_on_external_id"
    t.index ["staff_id"], name: "index_staff_passkeys_on_staff_id"
  end

  create_table "staff_recovery_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staff_time_based_one_time_passwords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id"
  end

  create_table "user_identity_emails", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_emails_on_user_id"
  end

  create_table "user_identity_one_time_passwords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
  end

  create_table "user_identity_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.bigint "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.binary "webauthn_id", null: false
    t.index ["user_id"], name: "index_user_identity_passkeys_on_user_id"
  end

  create_table "user_identity_social_apples", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_social_apples_on_user_id"
  end

  create_table "user_identity_social_googles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_social_googles_on_user_id"
  end

  create_table "user_identity_telephones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "number"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_telephones_on_user_id"
  end

  create_table "user_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.text "public_key"
    t.integer "sign_count"
    t.string "transports"
    t.datetime "updated_at", null: false
    t.string "user_handle"
    t.bigint "user_id", null: false
    t.index ["external_id"], name: "index_user_passkeys_on_external_id"
    t.index ["user_id"], name: "index_user_passkeys_on_user_id"
  end

  create_table "user_recovery_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_user_recovery_codes_on_user_id"
  end

  create_table "user_time_based_one_time_passwords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id"
  end

  add_foreign_key "apple_auths", "users", validate: false
  add_foreign_key "google_auths", "users", validate: false
  add_foreign_key "staff_passkeys", "staffs", validate: false
  add_foreign_key "user_passkeys", "users", validate: false
end
