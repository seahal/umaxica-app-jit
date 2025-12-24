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

ActiveRecord::Schema[8.2].define(version: 2025_12_24_173000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "staff_token_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_token_statuses_id_format"
  end

  create_table "staff_tokens", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.datetime "revoked_at"
    t.datetime "rotated_at"
    t.uuid "staff_id", null: false
    t.string "staff_token_status_id", default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_staff_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_staff_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_staff_tokens_on_refresh_token_digest", unique: true
    t.index ["revoked_at"], name: "index_staff_tokens_on_revoked_at"
    t.index ["staff_id"], name: "index_staff_tokens_on_staff_id"
    t.index ["staff_token_status_id"], name: "index_staff_tokens_on_staff_token_status_id"
    t.check_constraint "staff_token_status_id IS NULL OR staff_token_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_tokens_staff_token_status_id_format"
  end

  create_table "user_token_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_token_statuses_id_format"
  end

  create_table "user_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.datetime "revoked_at"
    t.datetime "rotated_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_token_status_id", default: "NONE", null: false
    t.index ["public_id"], name: "index_user_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_user_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_user_tokens_on_refresh_token_digest", unique: true
    t.index ["revoked_at"], name: "index_user_tokens_on_revoked_at"
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
    t.index ["user_token_status_id"], name: "index_user_tokens_on_user_token_status_id"
    t.check_constraint "user_token_status_id IS NULL OR user_token_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_tokens_user_token_status_id_format"
  end

  add_foreign_key "staff_tokens", "staff_token_statuses"
  add_foreign_key "user_tokens", "user_token_statuses"
end
