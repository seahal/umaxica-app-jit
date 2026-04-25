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

ActiveRecord::Schema[8.2].define(version: 2026_04_07_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "authorization_codes", force: :cascade do |t|
    t.string "acr", default: "aal1", null: false
    t.string "auth_method", default: "", null: false
    t.string "client_id", limit: 64, null: false
    t.string "code", limit: 64, null: false
    t.string "code_challenge", null: false
    t.string "code_challenge_method", limit: 8, default: "S256", null: false
    t.datetime "consumed_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.datetime "expires_at", null: false
    t.string "nonce"
    t.text "redirect_uri", null: false
    t.datetime "revoked_at"
    t.string "scope"
    t.bigint "staff_id"
    t.string "state"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["code"], name: "index_authorization_codes_on_code", unique: true
    t.index ["customer_id"], name: "index_authorization_codes_on_customer_id"
    t.index ["expires_at"], name: "index_authorization_codes_on_expires_at"
    t.index ["staff_id"], name: "index_authorization_codes_on_staff_id"
    t.index ["user_id"], name: "index_authorization_codes_on_user_id"
    t.check_constraint "user_id IS NOT NULL AND staff_id IS NULL AND customer_id IS NULL OR user_id IS NULL AND staff_id IS NOT NULL AND customer_id IS NULL OR user_id IS NULL AND staff_id IS NULL AND customer_id IS NOT NULL", name: "chk_authorization_codes_resource"
  end

  create_table "customer_token_binding_methods", force: :cascade do |t|
  end

  create_table "customer_token_dbsc_statuses", force: :cascade do |t|
  end

  create_table "customer_token_kinds", force: :cascade do |t|
  end

  create_table "customer_token_statuses", force: :cascade do |t|
  end

  create_table "customer_tokens", force: :cascade do |t|
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "customer_token_binding_method_id", default: 0, null: false
    t.bigint "customer_token_dbsc_status_id", default: 0, null: false
    t.bigint "customer_token_kind_id", default: 1, null: false
    t.bigint "customer_token_status_id", default: 0, null: false
    t.text "dbsc_challenge"
    t.datetime "dbsc_challenge_issued_at"
    t.jsonb "dbsc_public_key"
    t.string "dbsc_session_id"
    t.datetime "deletable_at", default: ::Float::INFINITY, null: false
    t.string "device_id", default: "", null: false
    t.string "device_id_digest"
    t.datetime "expired_at"
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
    t.index ["compromised_at"], name: "index_customer_tokens_on_compromised_at"
    t.index ["customer_id", "last_step_up_at"], name: "index_customer_tokens_on_customer_id_and_last_step_up_at"
    t.index ["customer_token_binding_method_id"], name: "index_customer_tokens_on_customer_token_binding_method_id"
    t.index ["customer_token_dbsc_status_id"], name: "index_customer_tokens_on_customer_token_dbsc_status_id"
    t.index ["customer_token_kind_id"], name: "index_customer_tokens_on_customer_token_kind_id"
    t.index ["customer_token_status_id"], name: "index_customer_tokens_on_customer_token_status_id"
    t.index ["dbsc_session_id"], name: "index_customer_tokens_on_dbsc_session_id", unique: true
    t.index ["deletable_at"], name: "index_customer_tokens_on_deletable_at"
    t.index ["device_id"], name: "index_customer_tokens_on_device_id"
    t.index ["device_id_digest"], name: "index_customer_tokens_on_device_id_digest"
    t.index ["expired_at"], name: "index_customer_tokens_on_expired_at"
    t.index ["public_id"], name: "index_customer_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_customer_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_customer_tokens_on_refresh_token_digest", unique: true
    t.index ["refresh_token_family_id"], name: "index_customer_tokens_on_refresh_token_family_id"
    t.index ["revoked_at"], name: "index_customer_tokens_on_revoked_at"
    t.index ["status"], name: "index_customer_tokens_on_status"
    t.check_constraint "customer_token_kind_id >= 0", name: "chk_customer_tokens_kind_id_positive"
    t.check_constraint "customer_token_status_id >= 0", name: "chk_customer_tokens_status_id_positive"
  end

  create_table "customer_verifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigserial "customer_token_id", null: false
    t.datetime "expires_at", null: false
    t.datetime "last_used_at"
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_token_id"], name: "index_customer_verifications_on_customer_token_id"
    t.index ["expires_at"], name: "index_customer_verifications_on_expires_at"
    t.index ["token_digest"], name: "index_customer_verifications_on_token_digest", unique: true
  end

  create_table "organization_invitations", force: :cascade do |t|
    t.string "code", limit: 32, null: false
    t.datetime "consumed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.bigint "invited_by_id", null: false
    t.bigint "organization_id", null: false
    t.bigint "role_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_organization_invitations_on_code", unique: true
    t.index ["email"], name: "index_organization_invitations_on_email"
    t.index ["invited_by_id"], name: "index_organization_invitations_on_invited_by_id"
    t.index ["organization_id"], name: "index_organization_invitations_on_organization_id"
  end

  create_table "reauth_sessions", force: :cascade do |t|
    t.bigint "actor_id", null: false
    t.string "actor_type", null: false
    t.integer "attempt_count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "expires_at", null: false
    t.string "method", null: false
    t.text "return_to", null: false
    t.string "scope", null: false
    t.string "status", null: false
    t.timestamptz "updated_at", null: false
    t.timestamptz "verified_at"
    t.index ["actor_type", "actor_id", "status"], name: "index_reauth_sessions_on_actor_type_and_actor_id_and_status"
    t.index ["expires_at"], name: "index_reauth_sessions_on_expires_at"
  end

  create_table "staff_token_binding_methods", force: :cascade do |t|
  end

  create_table "staff_token_dbsc_statuses", force: :cascade do |t|
  end

  create_table "staff_token_kinds", force: :cascade do |t|
  end

  create_table "staff_token_statuses", force: :cascade do |t|
  end

  create_table "staff_tokens", force: :cascade do |t|
    t.timestamptz "compromised_at"
    t.timestamptz "created_at", null: false
    t.text "dbsc_challenge"
    t.datetime "dbsc_challenge_issued_at"
    t.jsonb "dbsc_public_key"
    t.string "dbsc_session_id"
    t.timestamptz "deletable_at", default: ::Float::INFINITY, null: false
    t.string "device_id", default: "", null: false
    t.string "device_id_digest"
    t.timestamptz "expired_at"
    t.timestamptz "last_step_up_at"
    t.string "last_step_up_scope"
    t.timestamptz "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.timestamptz "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.string "refresh_token_family_id"
    t.integer "refresh_token_generation", default: 0, null: false
    t.timestamptz "revoked_at"
    t.timestamptz "rotated_at"
    t.bigint "staff_id", null: false
    t.bigint "staff_token_binding_method_id", default: 0, null: false
    t.bigint "staff_token_dbsc_status_id", default: 0, null: false
    t.bigint "staff_token_kind_id", default: 0, null: false
    t.bigint "staff_token_status_id", default: 0, null: false
    t.string "status", limit: 20, default: "active", null: false
    t.timestamptz "updated_at", null: false
    t.index ["compromised_at"], name: "index_staff_tokens_on_compromised_at"
    t.index ["dbsc_session_id"], name: "index_staff_tokens_on_dbsc_session_id", unique: true
    t.index ["deletable_at"], name: "index_staff_tokens_on_deletable_at"
    t.index ["device_id"], name: "index_staff_tokens_on_device_id"
    t.index ["device_id_digest"], name: "index_staff_tokens_on_device_id_digest"
    t.index ["expired_at"], name: "index_staff_tokens_on_expired_at"
    t.index ["public_id"], name: "index_staff_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_staff_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_staff_tokens_on_refresh_token_digest", unique: true
    t.index ["refresh_token_family_id"], name: "index_staff_tokens_on_refresh_token_family_id"
    t.index ["revoked_at"], name: "index_staff_tokens_on_revoked_at"
    t.index ["staff_id", "last_step_up_at"], name: "index_staff_tokens_on_staff_id_and_last_step_up_at"
    t.index ["staff_token_binding_method_id"], name: "index_staff_tokens_on_staff_token_binding_method_id"
    t.index ["staff_token_dbsc_status_id"], name: "index_staff_tokens_on_staff_token_dbsc_status_id"
    t.index ["staff_token_kind_id"], name: "index_staff_tokens_on_staff_token_kind_id"
    t.index ["staff_token_status_id"], name: "index_staff_tokens_on_staff_token_status_id"
    t.index ["status"], name: "index_staff_tokens_on_status"
    t.check_constraint "staff_token_kind_id >= 0", name: "chk_staff_tokens_kind_id_positive"
    t.check_constraint "staff_token_status_id >= 0", name: "chk_staff_tokens_status_id_positive"
  end

  create_table "staff_verifications", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "expires_at", null: false
    t.timestamptz "last_used_at"
    t.timestamptz "revoked_at"
    t.bigserial "staff_token_id", null: false
    t.string "token_digest", null: false
    t.timestamptz "updated_at", null: false
    t.index ["expires_at"], name: "index_staff_verifications_on_expires_at"
    t.index ["staff_token_id"], name: "index_staff_verifications_on_staff_token_id"
    t.index ["token_digest"], name: "index_staff_verifications_on_token_digest", unique: true
  end

  create_table "user_token_binding_methods", force: :cascade do |t|
  end

  create_table "user_token_dbsc_statuses", force: :cascade do |t|
  end

  create_table "user_token_kinds", force: :cascade do |t|
  end

  create_table "user_token_statuses", force: :cascade do |t|
  end

  create_table "user_tokens", force: :cascade do |t|
    t.timestamptz "compromised_at"
    t.timestamptz "created_at", null: false
    t.text "dbsc_challenge"
    t.datetime "dbsc_challenge_issued_at"
    t.jsonb "dbsc_public_key"
    t.string "dbsc_session_id"
    t.timestamptz "deletable_at", default: ::Float::INFINITY, null: false
    t.string "device_id", default: "", null: false
    t.string "device_id_digest"
    t.timestamptz "expired_at"
    t.timestamptz "last_step_up_at"
    t.string "last_step_up_scope"
    t.timestamptz "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.timestamptz "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.string "refresh_token_family_id"
    t.integer "refresh_token_generation", default: 0, null: false
    t.timestamptz "revoked_at"
    t.timestamptz "rotated_at"
    t.string "status", limit: 20, default: "active", null: false
    t.timestamptz "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "user_token_binding_method_id", default: 0, null: false
    t.bigint "user_token_dbsc_status_id", default: 0, null: false
    t.bigint "user_token_kind_id", default: 0, null: false
    t.bigint "user_token_status_id", default: 0, null: false
    t.index ["compromised_at"], name: "index_user_tokens_on_compromised_at"
    t.index ["dbsc_session_id"], name: "index_user_tokens_on_dbsc_session_id", unique: true
    t.index ["deletable_at"], name: "index_user_tokens_on_deletable_at"
    t.index ["device_id"], name: "index_user_tokens_on_device_id"
    t.index ["device_id_digest"], name: "index_user_tokens_on_device_id_digest"
    t.index ["expired_at"], name: "index_user_tokens_on_expired_at"
    t.index ["public_id"], name: "index_user_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_user_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_user_tokens_on_refresh_token_digest", unique: true
    t.index ["refresh_token_family_id"], name: "index_user_tokens_on_refresh_token_family_id"
    t.index ["revoked_at"], name: "index_user_tokens_on_revoked_at"
    t.index ["status"], name: "index_user_tokens_on_status"
    t.index ["user_id", "last_step_up_at"], name: "index_user_tokens_on_user_id_and_last_step_up_at"
    t.index ["user_token_binding_method_id"], name: "index_user_tokens_on_user_token_binding_method_id"
    t.index ["user_token_dbsc_status_id"], name: "index_user_tokens_on_user_token_dbsc_status_id"
    t.index ["user_token_kind_id"], name: "index_user_tokens_on_user_token_kind_id"
    t.index ["user_token_status_id"], name: "index_user_tokens_on_user_token_status_id"
    t.check_constraint "user_token_kind_id >= 0", name: "chk_user_tokens_kind_id_positive"
    t.check_constraint "user_token_status_id >= 0", name: "chk_user_tokens_status_id_positive"
  end

  create_table "user_verifications", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "expires_at", null: false
    t.timestamptz "last_used_at"
    t.timestamptz "revoked_at"
    t.string "token_digest", null: false
    t.timestamptz "updated_at", null: false
    t.bigserial "user_token_id", null: false
    t.index ["expires_at"], name: "index_user_verifications_on_expires_at"
    t.index ["token_digest"], name: "index_user_verifications_on_token_digest", unique: true
    t.index ["user_token_id"], name: "index_user_verifications_on_user_token_id"
  end

  add_foreign_key "customer_tokens", "customer_token_binding_methods", name: "fk_customer_tokens_on_customer_token_binding_method_id"
  add_foreign_key "customer_tokens", "customer_token_dbsc_statuses", name: "fk_customer_tokens_on_customer_token_dbsc_status_id"
  add_foreign_key "customer_tokens", "customer_token_kinds", name: "fk_customer_tokens_on_customer_token_kind_id"
  add_foreign_key "customer_tokens", "customer_token_statuses", name: "fk_customer_tokens_on_customer_token_status_id"
  add_foreign_key "customer_verifications", "customer_tokens"
  add_foreign_key "staff_tokens", "staff_token_binding_methods", name: "fk_staff_tokens_on_staff_token_binding_method_id"
  add_foreign_key "staff_tokens", "staff_token_dbsc_statuses", name: "fk_staff_tokens_on_staff_token_dbsc_status_id"
  add_foreign_key "staff_tokens", "staff_token_kinds", name: "fk_staff_tokens_on_staff_token_kind_id"
  add_foreign_key "staff_tokens", "staff_token_statuses", name: "fk_staff_tokens_on_staff_token_status_id"
  add_foreign_key "staff_verifications", "staff_tokens", on_delete: :cascade
  add_foreign_key "user_tokens", "user_token_binding_methods", name: "fk_user_tokens_on_user_token_binding_method_id"
  add_foreign_key "user_tokens", "user_token_dbsc_statuses", name: "fk_user_tokens_on_user_token_dbsc_status_id"
  add_foreign_key "user_tokens", "user_token_kinds", name: "fk_user_tokens_on_user_token_kind_id"
  add_foreign_key "user_tokens", "user_token_statuses", name: "fk_user_tokens_on_user_token_status_id"
  add_foreign_key "user_verifications", "user_tokens", on_delete: :cascade
end
