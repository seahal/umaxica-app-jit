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

ActiveRecord::Schema[8.2].define(version: 2025_12_11_110000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "apple_auths", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expires_at"
    t.string "name"
    t.string "provider"
    t.text "refresh_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_apple_auths_on_user_id"
  end

  create_table "google_auths", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_google_auths_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain"
    t.string "name"
    t.uuid "parent_organization"
    t.datetime "updated_at", null: false
  end

  create_table "role_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "role_id", null: false
    t.uuid "staff_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["staff_id", "role_id"], name: "index_role_assignments_on_staff_role", unique: true
    t.index ["user_id", "role_id"], name: "index_role_assignments_on_user_role", unique: true
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key"
    t.string "name"
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "staff_identity_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.text "previous_value"
    t.uuid "staff_id", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_staff_identity_audits_on_event_id"
    t.index ["staff_id"], name: "index_staff_identity_audits_on_staff_id"
  end

  create_table "staff_identity_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter"
    t.datetime "otp_expires_at"
    t.string "otp_private_key"
    t.bigint "staff_id"
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_emails_on_staff_id"
  end

  create_table "staff_identity_passkeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.uuid "staff_id", null: false
    t.datetime "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
    t.index ["webauthn_id"], name: "index_staff_identity_passkeys_on_webauthn_id", unique: true
  end

  create_table "staff_identity_secrets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "password_digest"
    t.uuid "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_secrets_on_staff_id"
  end

  create_table "staff_identity_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_telephones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.string "number"
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter"
    t.datetime "otp_expires_at"
    t.string "otp_private_key"
    t.bigint "staff_id"
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_telephones_on_staff_id"
  end

  create_table "staff_passkeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.text "public_key"
    t.integer "sign_count"
    t.uuid "staff_id", null: false
    t.string "transports"
    t.datetime "updated_at", null: false
    t.string "user_handle"
    t.index ["external_id"], name: "index_staff_passkeys_on_external_id"
    t.index ["staff_id"], name: "index_staff_passkeys_on_staff_id"
  end

  create_table "staff_recovery_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staffs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 255
    t.string "staff_identity_status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id"
    t.datetime "withdrawn_at"
    t.index ["public_id"], name: "index_staffs_on_public_id", unique: true
    t.index ["staff_identity_status_id"], name: "index_staffs_on_staff_identity_status_id"
    t.index ["withdrawn_at"], name: "index_staffs_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
  end

  create_table "user_apple_auths", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_apple_auths_on_user_id"
  end

  create_table "user_google_auths", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_google_auths_on_user_id"
  end

  create_table "user_identity_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.text "previous_value"
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["event_id"], name: "index_user_identity_audits_on_event_id"
    t.index ["user_id"], name: "index_user_identity_audits_on_user_id"
  end

  create_table "user_identity_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter"
    t.datetime "otp_expires_at"
    t.string "otp_private_key"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_emails_on_user_id"
  end

  create_table "user_identity_one_time_passwords", id: false, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.binary "hmac_based_one_time_password_id", null: false
    t.datetime "updated_at", null: false
    t.binary "user_id", null: false
  end

  create_table "user_identity_passkeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "webauthn_id", null: false
    t.index ["user_id"], name: "index_user_identity_passkeys_on_user_id"
    t.index ["webauthn_id"], name: "index_user_identity_passkeys_on_webauthn_id", unique: true
  end

  create_table "user_identity_secrets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_user_identity_secrets_on_user_id"
  end

  create_table "user_identity_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_telephones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.string "number"
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter"
    t.datetime "otp_expires_at"
    t.string "otp_private_key"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_user_identity_telephones_on_user_id"
  end

  create_table "user_organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id"], name: "index_user_organizations_on_organization_id"
    t.index ["user_id"], name: "index_user_organizations_on_user_id"
  end

  create_table "user_passkeys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id"
    t.string "name"
    t.text "public_key"
    t.integer "sign_count"
    t.string "transports"
    t.datetime "updated_at", null: false
    t.string "user_handle"
    t.uuid "user_id", null: false
    t.index ["external_id"], name: "index_user_passkeys_on_external_id"
    t.index ["user_id"], name: "index_user_passkeys_on_user_id"
  end

  create_table "user_recovery_codes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_user_recovery_codes_on_user_id"
  end

  create_table "user_time_based_one_time_passwords", id: false, force: :cascade do |t|
    t.binary "time_based_one_time_password_id", null: false
    t.binary "user_id", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 255
    t.datetime "updated_at", null: false
    t.string "user_identity_status_id", limit: 255, default: "NONE", null: false
    t.string "webauthn_id"
    t.datetime "withdrawn_at"
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["user_identity_status_id"], name: "index_users_on_user_identity_status_id"
    t.index ["withdrawn_at"], name: "index_users_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
  end

  add_foreign_key "apple_auths", "users"
  add_foreign_key "google_auths", "users"
  add_foreign_key "role_assignments", "roles"
  add_foreign_key "roles", "organizations"
  add_foreign_key "staff_identity_audits", "staff_identity_audit_events", column: "event_id"
  add_foreign_key "staff_identity_audits", "staffs"
  add_foreign_key "staff_identity_passkeys", "staffs"
  add_foreign_key "staff_identity_secrets", "staffs"
  add_foreign_key "staff_passkeys", "staffs"
  add_foreign_key "staffs", "staff_identity_statuses"
  add_foreign_key "user_identity_audits", "user_identity_audit_events", column: "event_id"
  add_foreign_key "user_identity_audits", "users"
  add_foreign_key "user_identity_passkeys", "users"
  add_foreign_key "user_identity_secrets", "users"
  add_foreign_key "user_organizations", "organizations"
  add_foreign_key "user_organizations", "users"
  add_foreign_key "user_passkeys", "users"
  add_foreign_key "users", "user_identity_statuses"
end
