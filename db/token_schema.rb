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

ActiveRecord::Schema[8.2].define(version: 2026_02_12_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "reauth_sessions", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.string "actor_type", null: false
    t.integer "attempt_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "method", null: false
    t.text "return_to", null: false
    t.string "scope", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["actor_type", "actor_id", "status"], name: "index_reauth_sessions_on_actor_type_and_actor_id_and_status"
    t.index ["expires_at"], name: "index_reauth_sessions_on_expires_at"
  end

  create_table "staff_token_kinds", force: :cascade do |t|
  end

  create_table "staff_token_statuses", force: :cascade do |t|
  end

  create_table "staff_tokens", force: :cascade do |t|
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.datetime "last_step_up_at"
    t.string "last_step_up_scope"
    t.datetime "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.string "refresh_token_family_id"
    t.integer "refresh_token_generation", default: 0, null: false
    t.datetime "revoked_at"
    t.datetime "rotated_at"
    t.bigint "staff_id", null: false
    t.bigint "staff_token_kind_id", default: 0, null: false
    t.bigint "staff_token_status_id", default: 0, null: false
    t.string "status", limit: 20, default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["compromised_at"], name: "index_staff_tokens_on_compromised_at"
    t.index ["public_id"], name: "index_staff_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_staff_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_staff_tokens_on_refresh_token_digest", unique: true
    t.index ["refresh_token_family_id"], name: "index_staff_tokens_on_refresh_token_family_id"
    t.index ["revoked_at"], name: "index_staff_tokens_on_revoked_at"
    t.index ["staff_id", "last_step_up_at"], name: "index_staff_tokens_on_staff_id_and_last_step_up_at"
    t.index ["staff_token_kind_id"], name: "index_staff_tokens_on_staff_token_kind_id"
    t.index ["staff_token_status_id"], name: "index_staff_tokens_on_staff_token_status_id"
    t.index ["status"], name: "index_staff_tokens_on_status"
    t.check_constraint "staff_token_kind_id >= 0", name: "chk_staff_tokens_kind_id_positive"
    t.check_constraint "staff_token_status_id >= 0", name: "chk_staff_tokens_status_id_positive"
  end

  create_table "user_token_kinds", force: :cascade do |t|
  end

  create_table "user_token_statuses", force: :cascade do |t|
  end

  create_table "user_tokens", force: :cascade do |t|
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.datetime "last_step_up_at"
    t.string "last_step_up_scope"
    t.datetime "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.string "refresh_token_family_id"
    t.integer "refresh_token_generation", default: 0, null: false
    t.datetime "revoked_at"
    t.datetime "rotated_at"
    t.string "status", limit: 20, default: "active", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "user_token_kind_id", default: 0, null: false
    t.bigint "user_token_status_id", default: 0, null: false
    t.index ["compromised_at"], name: "index_user_tokens_on_compromised_at"
    t.index ["public_id"], name: "index_user_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_user_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_user_tokens_on_refresh_token_digest", unique: true
    t.index ["refresh_token_family_id"], name: "index_user_tokens_on_refresh_token_family_id"
    t.index ["revoked_at"], name: "index_user_tokens_on_revoked_at"
    t.index ["status"], name: "index_user_tokens_on_status"
    t.index ["user_id", "last_step_up_at"], name: "index_user_tokens_on_user_id_and_last_step_up_at"
    t.index ["user_token_kind_id"], name: "index_user_tokens_on_user_token_kind_id"
    t.index ["user_token_status_id"], name: "index_user_tokens_on_user_token_status_id"
    t.check_constraint "user_token_kind_id >= 0", name: "chk_user_tokens_kind_id_positive"
    t.check_constraint "user_token_status_id >= 0", name: "chk_user_tokens_status_id_positive"
  end

  add_foreign_key "staff_tokens", "staff_token_kinds", name: "fk_staff_tokens_on_staff_token_kind_id"
  add_foreign_key "staff_tokens", "staff_token_statuses", name: "fk_staff_tokens_on_staff_token_status_id"
  add_foreign_key "user_tokens", "user_token_kinds", name: "fk_user_tokens_on_user_token_kind_id"
  add_foreign_key "user_tokens", "user_token_statuses", name: "fk_user_tokens_on_user_token_status_id"
end
