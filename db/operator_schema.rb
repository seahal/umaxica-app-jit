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

ActiveRecord::Schema[8.2].define(version: 2026_03_09_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "department_statuses", force: :cascade do |t|
  end

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "department_status_id", default: 0, null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.bigint "workspace_id"
    t.index ["department_status_id", "parent_id"], name: "index_departments_on_department_status_id_and_parent_id", unique: true
    t.index ["parent_id"], name: "index_departments_on_parent_id"
    t.index ["workspace_id"], name: "index_departments_on_workspace_id"
  end

  create_table "division_statuses", force: :cascade do |t|
  end

  create_table "divisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "division_status_id", default: 0, null: false
    t.string "name"
    t.bigint "organization_id"
    t.datetime "updated_at", null: false
    t.index ["division_status_id", "organization_id"], name: "index_divisions_on_division_status_id_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_divisions_on_organization_id"
  end

  create_table "operator_statuses", force: :cascade do |t|
  end

  create_table "operators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.integer "lock_version", default: 0, null: false
    t.string "moniker"
    t.string "public_id", null: false
    t.bigint "staff_id", null: false
    t.bigint "status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_operators_on_department_id"
    t.index ["public_id"], name: "index_operators_on_public_id", unique: true
    t.index ["staff_id"], name: "index_operators_on_staff_id"
    t.index ["status_id"], name: "index_operators_on_status_id"
  end

  create_table "organization_statuses", force: :cascade do |t|
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "department_id"
    t.string "domain", default: "", null: false
    t.string "name", default: "", null: false
    t.bigint "operator_id"
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.bigint "workspace_status_id", default: 0, null: false
    t.index ["department_id"], name: "index_organizations_on_department_id"
    t.index ["domain"], name: "index_organizations_on_domain", unique: true
    t.index ["operator_id"], name: "index_organizations_on_operator_id"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
    t.index ["workspace_status_id"], name: "index_organizations_on_workspace_status_id"
  end

  create_table "role_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.bigint "staff_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["staff_id"], name: "index_role_assignments_on_staff_id"
    t.index ["user_id"], name: "index_role_assignments_on_user_id"
  end

  create_table "staff_email_statuses", force: :cascade do |t|
  end

  create_table "staff_emails", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", null: false
    t.datetime "otp_expires_at"
    t.datetime "otp_last_sent_at"
    t.string "otp_private_key", null: false
    t.string "public_id", limit: 21, null: false
    t.bigint "staff_id", null: false
    t.bigint "staff_identity_email_status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((address)::text)", name: "index_staff_emails_on_lower_address", unique: true
    t.index ["address"], name: "index_staff_emails_on_address"
    t.index ["public_id"], name: "index_staff_emails_on_public_id", unique: true
    t.index ["staff_id"], name: "index_staff_emails_on_staff_id"
    t.index ["staff_identity_email_status_id"], name: "index_staff_emails_on_staff_identity_email_status_id"
  end

  create_table "staff_identity_audit_events", id: :string, force: :cascade do |t|
  end

  create_table "staff_identity_audits", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.string "event_id", null: false
    t.string "ip_address"
    t.text "previous_value"
    t.bigint "staff_id", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_audits_on_staff_id"
  end

  create_table "staff_identity_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
    t.index ["webauthn_id"], name: "index_staff_identity_passkeys_on_webauthn_id", unique: true
  end

  create_table "staff_identity_statuses", force: :cascade do |t|
  end

  create_table "staff_one_time_password_statuses", force: :cascade do |t|
  end

  create_table "staff_one_time_passwords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 21, null: false
    t.string "secret_key"
    t.bigint "staff_id", null: false
    t.bigint "staff_one_time_password_status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_staff_one_time_passwords_on_public_id", unique: true
    t.index ["staff_id"], name: "idx_staff_otps_on_staff_id"
    t.index ["staff_one_time_password_status_id"], name: "idx_staff_otps_on_status_id"
  end

  create_table "staff_operators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "operator_id", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["operator_id"], name: "index_staff_operators_on_operator_id"
    t.index ["staff_id", "operator_id"], name: "index_staff_operators_on_staff_id_and_operator_id", unique: true
  end

  create_table "staff_passkey_statuses", force: :cascade do |t|
  end

  create_table "staff_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.text "public_key", null: false
    t.integer "sign_count", null: false
    t.bigint "staff_id", null: false
    t.bigint "status_id", default: 0, null: false
    t.string "transports"
    t.datetime "updated_at", null: false
    t.string "user_handle"
    t.string "webauthn_id", default: "", null: false
    t.index ["external_id"], name: "index_staff_passkeys_on_external_id"
    t.index ["staff_id"], name: "index_staff_passkeys_on_staff_id"
    t.index ["status_id"], name: "index_staff_passkeys_on_status_id"
    t.index ["webauthn_id"], name: "index_staff_passkeys_on_webauthn_id", unique: true
  end

  create_table "staff_recovery_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in"
    t.string "recovery_code_digest"
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staff_secret_kinds", force: :cascade do |t|
  end

  create_table "staff_secret_statuses", force: :cascade do |t|
  end

  create_table "staff_secrets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "password_digest"
    t.string "public_id", limit: 21, null: false
    t.bigint "staff_id", null: false
    t.bigint "staff_identity_secret_status_id", default: 0, null: false
    t.bigint "staff_secret_kind_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_staff_secrets_on_public_id", unique: true
    t.index ["staff_id"], name: "index_staff_secrets_on_staff_id"
    t.index ["staff_identity_secret_status_id"], name: "index_staff_secrets_on_staff_identity_secret_status_id"
    t.index ["staff_secret_kind_id"], name: "index_staff_secrets_on_staff_secret_kind_id"
  end

  create_table "staff_statuses", force: :cascade do |t|
  end

  create_table "staff_telephone_statuses", force: :cascade do |t|
  end

  create_table "staff_telephones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.string "number", null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", null: false
    t.datetime "otp_expires_at"
    t.string "otp_private_key", null: false
    t.bigint "staff_id", null: false
    t.bigint "staff_identity_telephone_status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((number)::text)", name: "index_staff_telephones_on_lower_number", unique: true
    t.index ["staff_id"], name: "index_staff_telephones_on_staff_id"
    t.index ["staff_identity_telephone_status_id"], name: "index_staff_telephones_on_staff_identity_telephone_status_id"
  end

  create_table "staff_visibilities", force: :cascade do |t|
  end

  create_table "staffs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.boolean "multi_factor_enabled", default: false, null: false
    t.string "public_id", null: false
    t.datetime "shreddable_at", default: ::Float::INFINITY, null: false
    t.bigint "status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "visibility_id", default: 2, null: false
    t.string "webauthn_id"
    t.datetime "withdrawn_at"
    t.index ["public_id"], name: "index_staffs_on_public_id", unique: true
    t.index ["shreddable_at"], name: "index_staffs_on_shreddable_at"
    t.index ["status_id"], name: "index_staffs_on_status_id"
    t.index ["visibility_id"], name: "index_staffs_on_visibility_id"
    t.index ["withdrawn_at"], name: "index_staffs_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
  end

  create_table "user_workspaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "workspace_id", null: false
    t.index ["user_id"], name: "index_user_workspaces_on_user_id"
    t.index ["workspace_id"], name: "index_user_workspaces_on_workspace_id"
  end

  create_table "workspace_statuses", force: :cascade do |t|
  end

  create_table "workspaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "departments", "department_statuses", name: "fk_departments_on_department_status_id"
  add_foreign_key "departments", "departments", column: "parent_id", validate: false
  add_foreign_key "departments", "organizations", column: "workspace_id", on_delete: :nullify
  add_foreign_key "divisions", "division_statuses"
  add_foreign_key "divisions", "organizations", on_delete: :nullify
  add_foreign_key "operators", "departments", on_delete: :nullify, validate: false
  add_foreign_key "operators", "operator_statuses", column: "status_id"
  add_foreign_key "operators", "staffs", validate: false
  add_foreign_key "organizations", "organization_statuses", column: "workspace_status_id"
  add_foreign_key "role_assignments", "staffs", on_delete: :cascade, validate: false
  add_foreign_key "staff_emails", "staff_email_statuses", column: "staff_identity_email_status_id"
  add_foreign_key "staff_emails", "staffs", validate: false
  add_foreign_key "staff_identity_audits", "staff_identity_audit_events", column: "event_id", validate: false
  add_foreign_key "staff_identity_audits", "staffs", validate: false
  add_foreign_key "staff_identity_passkeys", "staffs", validate: false
  add_foreign_key "staff_one_time_passwords", "staff_one_time_password_statuses", name: "fk_staff_one_time_passwords_on_staff_one_time_password_status_i"
  add_foreign_key "staff_one_time_passwords", "staffs", on_delete: :cascade, validate: false
  add_foreign_key "staff_operators", "operators", on_delete: :cascade, validate: false
  add_foreign_key "staff_operators", "staffs", on_delete: :cascade, validate: false
  add_foreign_key "staff_passkeys", "staff_passkey_statuses", column: "status_id", validate: false
  add_foreign_key "staff_passkeys", "staffs", validate: false
  add_foreign_key "staff_recovery_codes", "staffs", validate: false
  add_foreign_key "staff_secrets", "staff_secret_kinds", name: "fk_staff_secrets_on_staff_secret_kind_id"
  add_foreign_key "staff_secrets", "staff_secret_statuses", column: "staff_identity_secret_status_id"
  add_foreign_key "staff_secrets", "staffs", validate: false
  add_foreign_key "staff_telephones", "staff_telephone_statuses", column: "staff_identity_telephone_status_id"
  add_foreign_key "staff_telephones", "staffs", validate: false
  add_foreign_key "staffs", "staff_statuses", column: "status_id"
  add_foreign_key "staffs", "staff_visibilities", column: "visibility_id"
  add_foreign_key "user_workspaces", "workspaces", validate: false
end
