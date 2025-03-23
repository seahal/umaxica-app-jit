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

ActiveRecord::Schema[8.1].define(version: 2025_02_20_135926) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "access_audit_trails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
  end

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.uuid "persona_id"
    t.uuid "session_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
  end

  create_table "emails", primary_key: "address", id: { type: :string, limit: 256 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "encrypted_password", limit: 255
    t.datetime "last_sign_in_at"
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "display_name", limit: 32
    t.string "encrypted_password", limit: 255
    t.datetime "last_sign_in_at"
    t.datetime "updated_at", null: false
  end
end
