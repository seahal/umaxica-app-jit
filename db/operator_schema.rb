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

ActiveRecord::Schema[8.2].define(version: 2026_01_08_100600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_admin_identity_statuses_on_lower_id", unique: true
  end

  create_table "admins", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "department_id"
    t.string "moniker"
    t.string "public_id"
    t.uuid "staff_id", null: false
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_admins_on_department_id"
    t.index ["public_id"], name: "index_admins_on_public_id", unique: true
    t.index ["staff_id"], name: "index_admins_on_staff_id"
    t.index ["status_id"], name: "index_admins_on_status_id"
  end

  create_table "departments", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "department_status_id", limit: 255, default: "NEYO", null: false
    t.string "name", null: false
    t.uuid "parent_id"
    t.datetime "updated_at", null: false
    t.uuid "workspace_id"
    t.index ["department_status_id", "parent_id"], name: "index_departments_on_department_status_id_and_parent_id", unique: true
    t.index ["department_status_id", "parent_id"], name: "index_departments_on_status_and_parent", unique: true
    t.index ["department_status_id"], name: "index_departments_on_department_status_id"
    t.index ["parent_id"], name: "index_departments_on_parent_id"
    t.index ["workspace_id"], name: "index_departments_on_workspace_id"
  end

  create_table "division_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_division_statuses_on_lower_id", unique: true
  end

  create_table "divisions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "division_status_id", limit: 255, null: false
    t.uuid "organization_id"
    t.uuid "parent_id"
    t.datetime "updated_at", null: false
    t.index ["division_status_id"], name: "index_divisions_on_division_status_id"
    t.index ["organization_id"], name: "index_divisions_on_organization_id"
    t.index ["parent_id", "division_status_id"], name: "index_divisions_unique", unique: true
  end

  create_table "organization_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_department_statuses_on_lower_id", unique: true
  end

  create_table "organizations", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "admin_id"
    t.datetime "created_at", null: false
    t.uuid "department_id"
    t.string "domain", default: "", null: false
    t.string "name", default: "", null: false
    t.uuid "parent_id"
    t.uuid "parent_organization", default: "00000000-0000-0000-0000-000000000000", null: false
    t.datetime "updated_at", null: false
    t.string "workspace_status_id", limit: 255
    t.index ["admin_id"], name: "index_organizations_on_admin_id"
    t.index ["department_id"], name: "index_organizations_on_department_id"
    t.index ["domain"], name: "index_organizations_on_domain", unique: true
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
    t.index ["workspace_status_id"], name: "index_organizations_on_workspace_status_id"
  end

  create_table "role_assignments", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "role_id", null: false
    t.uuid "staff_id"
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["staff_id", "role_id"], name: "index_role_assignments_on_staff_role", unique: true
    t.index ["user_id", "role_id"], name: "index_role_assignments_on_user_role", unique: true
    t.check_constraint "user_id IS NOT NULL AND staff_id IS NULL OR staff_id IS NOT NULL AND user_id IS NULL", name: "role_assignments_user_or_staff_check"
  end

  create_table "staff_admins", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "admin_id", null: false
    t.datetime "created_at", null: false
    t.uuid "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_staff_admins_on_admin_id"
    t.index ["staff_id", "admin_id"], name: "index_staff_admins_on_staff_id_and_admin_id", unique: true
  end

  create_table "staff_email_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_staff_identity_email_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_email_statuses_id_format"
  end

  create_table "staff_emails", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "address", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.datetime "otp_last_sent_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.uuid "staff_id", null: false
    t.string "staff_identity_email_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.datetime "updated_at", null: false
    t.index "lower((address)::text)", name: "index_staff_identity_emails_on_lower_address"
    t.index ["otp_last_sent_at"], name: "index_staff_emails_on_otp_last_sent_at"
    t.index ["staff_id"], name: "index_staff_emails_on_staff_id"
    t.index ["staff_identity_email_status_id"], name: "index_staff_emails_on_staff_identity_email_status_id"
    t.check_constraint "staff_identity_email_status_id IS NULL OR staff_identity_email_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_emails_staff_identity_email_status_id_format"
  end

  create_table "staff_identity_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audit_levels", id: :string, default: "NEYO", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NEYO", null: false
    t.text "previous_value"
    t.uuid "staff_id", null: false
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_staff_identity_audits_on_event_id"
    t.index ["level_id"], name: "index_staff_identity_audits_on_level_id"
    t.index ["staff_id"], name: "index_staff_identity_audits_on_staff_id"
    t.index ["subject_id"], name: "index_staff_identity_audits_on_subject_id"
  end

  create_table "staff_passkey_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_staff_identity_passkey_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_passkey_statuses_id_format"
  end

  create_table "staff_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.uuid "staff_id", null: false
    t.string "staff_passkey_status_id", limit: 255, default: "ACTIVE", null: false
    t.datetime "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
    t.index ["staff_passkey_status_id"], name: "idx_on_staff_identity_passkey_status_id_159c890738"
    t.index ["webauthn_id"], name: "index_staff_identity_passkeys_on_webauthn_id", unique: true
  end

  create_table "staff_recovery_codes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in", null: false
    t.string "recovery_code_digest", default: "", null: false
    t.uuid "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staff_secret_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_staff_identity_secret_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_secret_statuses_id_format"
  end

  create_table "staff_secrets", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.datetime "last_used_at", default: -::Float::INFINITY, null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.uuid "staff_id", null: false
    t.string "staff_identity_secret_status_id", limit: 255, default: "ACTIVE", null: false
    t.datetime "updated_at", null: false
    t.integer "uses_remaining", default: 1, null: false
    t.index ["expires_at"], name: "index_staff_secrets_on_expires_at"
    t.index ["staff_id"], name: "index_staff_secrets_on_staff_id"
    t.index ["staff_identity_secret_status_id"], name: "index_staff_secrets_on_staff_identity_secret_status_id"
    t.check_constraint "staff_identity_secret_status_id IS NULL OR staff_identity_secret_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_secrets_staff_identity_secret_status_id_94c4"
    t.check_constraint "uses_remaining >= 0", name: "chk_staff_identity_secrets_uses_remaining_non_negative"
  end

  create_table "staff_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_staff_identity_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_statuses_id_format"
  end

  create_table "staff_telephone_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_staff_identity_telephone_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_telephone_statuses_id_format"
  end

  create_table "staff_telephones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.string "number", default: "", null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.uuid "staff_id", null: false
    t.string "staff_identity_telephone_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.datetime "updated_at", null: false
    t.index "lower((number)::text)", name: "index_staff_identity_telephones_on_lower_number"
    t.index ["staff_id"], name: "index_staff_telephones_on_staff_id"
    t.index ["staff_identity_telephone_status_id"], name: "index_staff_telephones_on_staff_identity_telephone_status_id"
    t.check_constraint "staff_identity_telephone_status_id IS NULL OR staff_identity_telephone_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_telephones_staff_identity_telephone_status_i"
  end

  create_table "staffs", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 255, default: ""
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id", default: "", null: false
    t.datetime "withdrawn_at", default: ::Float::INFINITY
    t.index ["public_id"], name: "index_staffs_on_public_id", unique: true
    t.index ["status_id"], name: "index_staffs_on_status_id"
    t.index ["withdrawn_at"], name: "index_staffs_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
    t.check_constraint "status_id IS NULL OR status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staffs_staff_identity_status_id_format"
  end

  create_table "user_workspaces", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "workspace_id", null: false
    t.index ["user_id"], name: "index_user_workspaces_on_user_id"
    t.index ["workspace_id"], name: "index_user_workspaces_on_workspace_id"
  end

  create_table "workspace_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "admins", "admin_statuses", column: "status_id"
  add_foreign_key "admins", "departments", on_delete: :nullify
  add_foreign_key "admins", "staffs"
  add_foreign_key "departments", "departments", column: "parent_id", on_delete: :restrict
  add_foreign_key "departments", "organization_statuses", column: "department_status_id", on_delete: :restrict
  add_foreign_key "departments", "organizations", column: "workspace_id", on_delete: :restrict
  add_foreign_key "divisions", "division_statuses"
  add_foreign_key "divisions", "divisions", column: "parent_id"
  add_foreign_key "divisions", "organizations"
  add_foreign_key "organizations", "workspace_statuses", on_delete: :restrict
  add_foreign_key "role_assignments", "staffs", on_delete: :cascade
  add_foreign_key "staff_admins", "admins", on_delete: :cascade
  add_foreign_key "staff_admins", "staffs", on_delete: :cascade
  add_foreign_key "staff_emails", "staff_email_statuses", column: "staff_identity_email_status_id"
  add_foreign_key "staff_emails", "staffs"
  add_foreign_key "staff_passkeys", "staff_passkey_statuses", validate: false
  add_foreign_key "staff_passkeys", "staffs"
  add_foreign_key "staff_recovery_codes", "staffs"
  add_foreign_key "staff_secrets", "staff_secret_statuses", column: "staff_identity_secret_status_id"
  add_foreign_key "staff_secrets", "staffs"
  add_foreign_key "staff_telephones", "staff_telephone_statuses", column: "staff_identity_telephone_status_id"
  add_foreign_key "staff_telephones", "staffs"
  add_foreign_key "staffs", "staff_statuses", column: "status_id"
  add_foreign_key "user_workspaces", "departments", column: "workspace_id"
end
