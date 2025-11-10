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

ActiveRecord::Schema[8.1].define(version: 2025_11_03_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "email_preference_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "context", limit: 32, null: false
    t.datetime "created_at", null: false
    t.string "email_address", limit: 1000, null: false
    t.jsonb "preferences", default: {}, null: false
    t.datetime "sent_at"
    t.string "token_digest", limit: 64, null: false
    t.datetime "token_expires_at", null: false
    t.datetime "token_used_at"
    t.datetime "updated_at", null: false
    t.index ["context"], name: "index_email_preference_requests_on_context"
    t.index ["token_digest"], name: "index_email_preference_requests_on_token_digest", unique: true
  end

  create_table "hmac_based_one_time_passwords", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_otp_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "private_key", limit: 1024, null: false
    t.datetime "updated_at", null: false
  end

  create_table "identifier_region_codes", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "identifier_region_codes_universal_staff_identifiers", id: false, force: :cascade do |t|
    t.bigint "identifier_region_code_id", null: false
    t.bigint "universal_staff_identifier_id", null: false
    t.index ["identifier_region_code_id", "universal_staff_identifier_id"], name: "idx_on_identifier_region_code_id_universal_staff_id_cb9119c8ef"
    t.index ["universal_staff_identifier_id", "identifier_region_code_id"], name: "idx_on_universal_staff_identifier_id_identifier_reg_936e7af644"
  end

  create_table "identifier_region_codes_universal_user_identifiers", id: false, force: :cascade do |t|
    t.bigint "identifier_region_code_id", null: false
    t.bigint "universal_user_identifier_id", null: false
    t.index ["identifier_region_code_id", "universal_user_identifier_id"], name: "idx_on_identifier_region_code_id_universal_user_ide_59f36db5f2"
    t.index ["universal_user_identifier_id", "identifier_region_code_id"], name: "idx_on_universal_user_identifier_id_identifier_regi_1475aa39aa"
  end

  create_table "time_based_one_time_passwords", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_otp_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "private_key", limit: 1024, null: false
    t.datetime "updated_at", null: false
  end

  create_table "universal_email_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "universal_staff_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_otp_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "otp_private_key"
    t.datetime "updated_at", null: false
  end

  create_table "universal_telephone_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "universal_user_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_otp_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "otp_private_key"
    t.datetime "updated_at", null: false
  end
end
