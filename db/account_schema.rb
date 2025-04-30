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

ActiveRecord::Schema[8.0].define(version: 2025_04_29_234642) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "emails", id: :binary, default: "", force: :cascade do |t|
    t.string "address", limit: 512, null: false
    t.string "type", null: false
    t.string "entryable_type", null: false
    t.binary "entryable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_emails", id: :binary, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_hmac_based_one_time_passwords", id: false, force: :cascade do |t|
    t.binary "staff_id", null: false
    t.binary "hmac_based_one_time_password_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_telephones", force: :cascade do |t|
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_time_based_one_time_passwords", id: false, force: :cascade do |t|
    t.binary "staff_id", null: false
    t.binary "time_based_one_time_password_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", id: :binary, force: :cascade do |t|
    t.string "otp_private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "telephones", id: :binary, force: :cascade do |t|
    t.string "number"
    t.string "entryable_type"
    t.binary "entryable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_emails", id: :binary, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_hmac_based_one_time_passwords", id: false, force: :cascade do |t|
    t.binary "user_id", null: false
    t.binary "hmac_based_one_time_password_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_telephones", force: :cascade do |t|
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_time_based_one_time_passwords", id: false, force: :cascade do |t|
    t.binary "user_id", null: false
    t.binary "time_based_one_time_password_id", null: false
  end

  create_table "users", id: :binary, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
