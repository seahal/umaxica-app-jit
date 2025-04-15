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

ActiveRecord::Schema[8.1].define(version: 2025_04_02_105648) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "emails", id: :binary, default: "", force: :cascade do |t|
    t.string "address", limit: 512, null: false
    t.datetime "created_at", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", id: :binary, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "encrypted_password", limit: 255
    t.datetime "last_sign_in_at"
    t.datetime "updated_at", null: false
  end

  create_table "telephones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "number"
    t.binary "universal_telephone_identifiers_id"
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :binary, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "display_name", limit: 32
    t.string "encrypted_password", limit: 255
    t.datetime "last_sign_in_at"
    t.datetime "updated_at", null: false
  end
end
