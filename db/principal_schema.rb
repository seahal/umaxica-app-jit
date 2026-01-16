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

ActiveRecord::Schema[8.2].define(version: 2026_01_15_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "accountable_id", null: false
    t.string "accountable_type", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["accountable_type", "accountable_id"], name: "index_accounts_on_accountable_type_and_accountable_id", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "apple_auths", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "access_token", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.datetime "expires_at", null: false
    t.string "name", default: "", null: false
    t.string "provider", default: "", null: false
    t.text "refresh_token", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_apple_auths_on_user_id"
  end

  create_table "client_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_client_identity_statuses_on_lower_id", unique: true
  end

  create_table "clients", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "division_id"
    t.integer "lock_version", default: 0, null: false
    t.string "moniker"
    t.string "public_id"
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["division_id"], name: "index_clients_on_division_id"
    t.index ["public_id"], name: "index_clients_on_public_id", unique: true
    t.index ["status_id"], name: "index_clients_on_status_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "google_auths", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "access_token", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.datetime "expires_at", null: false
    t.string "image_url", default: "", null: false
    t.string "name", default: "", null: false
    t.string "provider", default: "", null: false
    t.text "raw_info", null: false
    t.text "refresh_token", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_google_auths_on_user_id"
  end

  create_table "roles", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "key", default: "", null: false
    t.string "name", default: "", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "user_client_deletions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_client_deletions_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_client_deletions_on_user_id_and_client_id", unique: true
  end

  create_table "user_client_discoveries", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_client_discoveries_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_client_discoveries_on_user_id_and_client_id", unique: true
  end

  create_table "user_client_impersonations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_client_impersonations_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_client_impersonations_on_user_id_and_client_id", unique: true
  end

  create_table "user_client_observations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_client_observations_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_client_observations_on_user_id_and_client_id", unique: true
  end

  create_table "user_client_revocations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_client_revocations_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_client_revocations_on_user_id_and_client_id", unique: true
  end

  create_table "user_client_suspensions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_client_suspensions_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_client_suspensions_on_user_id_and_client_id", unique: true
  end

  create_table "user_clients", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["client_id"], name: "index_user_clients_on_client_id"
    t.index ["user_id", "client_id"], name: "index_user_clients_on_user_id_and_client_id", unique: true
    t.index ["user_id"], name: "index_user_clients_on_user_id"
  end

  create_table "user_email_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_email_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_email_statuses_id_format"
  end

  create_table "user_emails", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "address", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.datetime "otp_last_sent_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_email_status_id", limit: 255, default: "NEYO", null: false
    t.index "lower((address)::text)", name: "index_user_identity_emails_on_lower_address", unique: true
    t.index ["otp_last_sent_at"], name: "index_user_emails_on_otp_last_sent_at"
    t.index ["user_id"], name: "index_user_emails_on_user_id"
    t.index ["user_identity_email_status_id"], name: "index_user_emails_on_user_identity_email_status_id"
    t.check_constraint "user_identity_email_status_id IS NULL OR user_identity_email_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_emails_user_identity_email_status_id_format"
  end

  create_table "user_identity_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audit_levels", id: :string, default: "NEYO", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NEYO", null: false
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["event_id"], name: "index_user_identity_audits_on_event_id"
    t.index ["level_id"], name: "index_user_identity_audits_on_level_id"
    t.index ["subject_id"], name: "index_user_identity_audits_on_subject_id"
    t.index ["user_id"], name: "index_user_identity_audits_on_user_id"
  end

  create_table "user_memberships", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "left_at", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "workspace_id", null: false
    t.index ["user_id", "workspace_id"], name: "index_user_memberships_on_user_id_and_workspace_id", unique: true
    t.index ["workspace_id"], name: "index_user_memberships_on_workspace_id"
  end

  create_table "user_one_time_password_statuses", id: :string, default: "NEYO", force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_otp_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_one_time_password_statuses_id_format"
  end

  create_table "user_one_time_passwords", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_otp_at", default: -::Float::INFINITY, null: false
    t.string "private_key", limit: 1024, default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_one_time_password_status_id", default: "NEYO", null: false
    t.index ["user_id"], name: "index_user_one_time_passwords_on_user_id"
    t.index ["user_identity_one_time_password_status_id"], name: "idx_on_user_identity_one_time_password_status_id_c03cdf0b39"
    t.check_constraint "user_identity_one_time_password_status_id IS NULL OR user_identity_one_time_password_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_one_time_passwords_user_identity_one_time_pas"
  end

  create_table "user_passkey_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_passkey_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_passkey_statuses_id_format"
  end

  create_table "user_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_passkey_status_id", limit: 255, default: "ACTIVE", null: false
    t.string "webauthn_id", default: "", null: false
    t.index ["user_id"], name: "index_user_identity_passkeys_on_user_id"
    t.index ["user_passkey_status_id"], name: "idx_on_user_identity_passkey_status_id_f979a7d699"
    t.index ["webauthn_id"], name: "index_user_identity_passkeys_on_webauthn_id", unique: true
    t.check_constraint "user_passkey_status_id IS NULL OR user_passkey_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_passkeys_user_identity_passkey_status_id_0993"
  end

  create_table "user_secret_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_secret_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_secret_statuses_id_format"
  end

  create_table "user_secrets", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.datetime "last_used_at", default: -::Float::INFINITY, null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_secret_status_id", limit: 255, default: "ACTIVE", null: false
    t.integer "uses_remaining", default: 1, null: false
    t.index ["expires_at"], name: "index_user_secrets_on_expires_at"
    t.index ["user_id"], name: "index_user_secrets_on_user_id"
    t.index ["user_identity_secret_status_id"], name: "index_user_secrets_on_user_identity_secret_status_id"
    t.check_constraint "user_identity_secret_status_id IS NULL OR user_identity_secret_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_secrets_user_identity_secret_status_id_format"
    t.check_constraint "uses_remaining >= 0", name: "chk_user_identity_secrets_uses_remaining_non_negative"
  end

  create_table "user_social_apple_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_apple_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_apple_statuses_id_format"
  end

  create_table "user_social_apples", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.integer "expires_at", null: false
    t.string "image", default: "", null: false
    t.string "provider", default: "apple", null: false
    t.string "refresh_token", default: "", null: false
    t.string "token", default: "", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_social_apple_status_id", limit: 255, default: "ACTIVE", null: false
    t.index ["expires_at"], name: "index_user_social_apples_on_expires_at"
    t.index ["uid", "provider"], name: "index_user_social_apples_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_user_identity_social_apples_on_user_id_unique", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_identity_social_apple_status_id"], name: "idx_on_user_identity_social_apple_status_id_93441f369d"
    t.check_constraint "user_identity_social_apple_status_id IS NULL OR user_identity_social_apple_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_apples_user_identity_social_apple_stat"
  end

  create_table "user_social_google_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_google_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_google_statuses_id_format"
  end

  create_table "user_social_googles", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.integer "expires_at", null: false
    t.string "image", default: "", null: false
    t.string "provider", default: "google_oauth2", null: false
    t.string "refresh_token", default: "", null: false
    t.string "token", default: "", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_social_google_status_id", limit: 255, default: "ACTIVE", null: false
    t.index ["expires_at"], name: "index_user_social_googles_on_expires_at"
    t.index ["uid", "provider"], name: "index_user_social_googles_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_user_identity_social_googles_on_user_id_unique", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_identity_social_google_status_id"], name: "idx_on_user_identity_social_google_status_id_f4bfb6ffdd"
    t.check_constraint "user_identity_social_google_status_id IS NULL OR user_identity_social_google_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_googles_user_identity_social_google_st"
  end

  create_table "user_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_statuses_id_format"
  end

  create_table "user_telephone_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_telephone_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_telephone_statuses_id_format"
  end

  create_table "user_telephones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.string "number", default: "", null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_telephone_status_id", limit: 255, default: "NEYO", null: false
    t.index "lower((number)::text)", name: "index_user_identity_telephones_on_lower_number"
    t.index ["user_id"], name: "index_user_telephones_on_user_id"
    t.index ["user_identity_telephone_status_id"], name: "index_user_telephones_on_user_identity_telephone_status_id"
    t.check_constraint "user_identity_telephone_status_id IS NULL OR user_identity_telephone_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_telephones_user_identity_telephone_status_id_"
  end

  create_table "users", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "public_id", limit: 255, default: ""
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id", default: "", null: false
    t.datetime "withdrawn_at", default: ::Float::INFINITY
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["status_id"], name: "index_users_on_status_id"
    t.index ["withdrawn_at"], name: "index_users_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
    t.check_constraint "status_id IS NULL OR status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_users_user_identity_status_id_format"
  end

  add_foreign_key "apple_auths", "users"
  add_foreign_key "clients", "client_statuses", column: "status_id"
  add_foreign_key "clients", "users"
  add_foreign_key "google_auths", "users"
  add_foreign_key "user_client_deletions", "clients"
  add_foreign_key "user_client_deletions", "users"
  add_foreign_key "user_client_discoveries", "clients"
  add_foreign_key "user_client_discoveries", "users"
  add_foreign_key "user_client_impersonations", "clients"
  add_foreign_key "user_client_impersonations", "users"
  add_foreign_key "user_client_observations", "clients"
  add_foreign_key "user_client_observations", "users"
  add_foreign_key "user_client_revocations", "clients"
  add_foreign_key "user_client_revocations", "users"
  add_foreign_key "user_client_suspensions", "clients"
  add_foreign_key "user_client_suspensions", "users"
  add_foreign_key "user_clients", "clients", on_delete: :cascade
  add_foreign_key "user_clients", "users", on_delete: :cascade
  add_foreign_key "user_emails", "user_email_statuses", column: "user_identity_email_status_id"
  add_foreign_key "user_emails", "users"
  add_foreign_key "user_identity_audits", "user_identity_audit_events", column: "event_id"
  add_foreign_key "user_memberships", "users"
  add_foreign_key "user_one_time_passwords", "user_one_time_password_statuses", column: "user_identity_one_time_password_status_id"
  add_foreign_key "user_one_time_passwords", "users", validate: false
  add_foreign_key "user_passkeys", "user_passkey_statuses"
  add_foreign_key "user_passkeys", "users"
  add_foreign_key "user_secrets", "user_secret_statuses", column: "user_identity_secret_status_id"
  add_foreign_key "user_secrets", "users"
  add_foreign_key "user_social_apples", "user_social_apple_statuses", column: "user_identity_social_apple_status_id"
  add_foreign_key "user_social_apples", "users"
  add_foreign_key "user_social_googles", "user_social_google_statuses", column: "user_identity_social_google_status_id"
  add_foreign_key "user_social_googles", "users"
  add_foreign_key "user_telephones", "user_telephone_statuses", column: "user_identity_telephone_status_id"
  add_foreign_key "user_telephones", "users"
  add_foreign_key "users", "user_statuses", column: "status_id"
end
