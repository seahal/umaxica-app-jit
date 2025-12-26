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

ActiveRecord::Schema[8.2].define(version: 2025_12_26_013002) do
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

  create_table "avatar_capabilities", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_avatar_capabilities_on_key", unique: true
  end

  create_table "avatar_membership_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_avatar_membership_statuses_on_key", unique: true
  end

  create_table "avatar_memberships", id: :string, force: :cascade do |t|
    t.string "actor_id", null: false
    t.string "avatar_id", null: false
    t.string "avatar_membership_status_id"
    t.datetime "created_at", null: false
    t.string "granted_by_actor_id"
    t.string "role_id", null: false
    t.datetime "updated_at", null: false
    t.timestamptz "valid_from", null: false
    t.timestamptz "valid_to", default: ::Float::INFINITY, null: false
    t.index ["actor_id"], name: "index_avatar_memberships_on_actor_id", where: "(valid_to = 'infinity'::timestamp with time zone)"
    t.index ["avatar_id", "actor_id"], name: "index_avatar_memberships_on_avatar_id_and_actor_id", unique: true, where: "(valid_to = 'infinity'::timestamp with time zone)"
    t.index ["avatar_membership_status_id"], name: "index_avatar_memberships_on_avatar_membership_status_id"
  end

  create_table "avatar_moniker_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_avatar_moniker_statuses_on_key", unique: true
  end

  create_table "avatar_monikers", id: :string, force: :cascade do |t|
    t.string "avatar_id", null: false
    t.string "avatar_moniker_status_id"
    t.datetime "created_at", null: false
    t.string "moniker", null: false
    t.string "set_by_actor_id"
    t.datetime "updated_at", null: false
    t.timestamptz "valid_from", null: false
    t.timestamptz "valid_to", default: ::Float::INFINITY, null: false
    t.index ["avatar_id", "valid_from"], name: "index_avatar_monikers_on_avatar_id_and_valid_from", order: { valid_from: :desc }
    t.index ["avatar_id"], name: "index_avatar_monikers_on_avatar_id", unique: true, where: "(valid_to = 'infinity'::timestamp with time zone)"
    t.index ["avatar_moniker_status_id"], name: "index_avatar_monikers_on_avatar_moniker_status_id"
  end

  create_table "avatar_ownership_periods", id: :string, force: :cascade do |t|
    t.string "avatar_id", null: false
    t.string "avatar_ownership_status_id"
    t.datetime "created_at", null: false
    t.string "owner_organization_id", null: false
    t.string "transferred_by_actor_id"
    t.datetime "updated_at", null: false
    t.timestamptz "valid_from", null: false
    t.timestamptz "valid_to", default: ::Float::INFINITY, null: false
    t.index ["avatar_id"], name: "index_avatar_ownership_periods_on_avatar_id", unique: true, where: "(valid_to = 'infinity'::timestamp with time zone)"
    t.index ["avatar_ownership_status_id"], name: "index_avatar_ownership_periods_on_avatar_ownership_status_id"
    t.index ["owner_organization_id"], name: "index_avatar_ownership_periods_on_owner_organization_id", where: "(valid_to = 'infinity'::timestamp with time zone)"
  end

  create_table "avatar_ownership_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_avatar_ownership_statuses_on_key", unique: true
  end

  create_table "avatar_permissions", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_avatar_permissions_on_key", unique: true
  end

  create_table "avatar_role_permissions", id: :string, force: :cascade do |t|
    t.string "avatar_permission_id", null: false
    t.string "avatar_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["avatar_permission_id"], name: "index_avatar_role_permissions_on_avatar_permission_id"
    t.index ["avatar_role_id", "avatar_permission_id"], name: "uniq_avatar_role_permissions", unique: true
  end

  create_table "avatar_roles", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_avatar_roles_on_key", unique: true
  end

  create_table "avatars", id: :string, force: :cascade do |t|
    t.string "active_handle_id", null: false
    t.string "avatar_status_id"
    t.string "capability_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "image_data", default: {}, null: false
    t.string "moniker", null: false
    t.string "owner_organization_id"
    t.string "public_id", null: false
    t.string "representing_organization_id"
    t.datetime "updated_at", null: false
    t.index ["active_handle_id"], name: "index_avatars_on_active_handle_id"
    t.index ["capability_id"], name: "index_avatars_on_capability_id"
    t.index ["owner_organization_id"], name: "index_avatars_on_owner_organization_id"
    t.index ["public_id"], name: "index_avatars_on_public_id", unique: true
    t.index ["representing_organization_id"], name: "index_avatars_on_representing_organization_id"
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

  create_table "handle_assignment_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_handle_assignment_statuses_on_key", unique: true
  end

  create_table "handle_assignments", id: :string, force: :cascade do |t|
    t.string "assigned_by_actor_id"
    t.string "avatar_id", null: false
    t.datetime "created_at", null: false
    t.string "handle_assignment_status_id"
    t.string "handle_id", null: false
    t.datetime "updated_at", null: false
    t.timestamptz "valid_from", null: false
    t.timestamptz "valid_to", default: ::Float::INFINITY, null: false
    t.index ["avatar_id", "valid_from"], name: "index_handle_assignments_on_avatar_id_and_valid_from", order: { valid_from: :desc }
    t.index ["avatar_id"], name: "index_handle_assignments_on_avatar_id", unique: true, where: "(valid_to = 'infinity'::timestamp with time zone)"
    t.index ["handle_assignment_status_id"], name: "index_handle_assignments_on_handle_assignment_status_id"
    t.index ["handle_id", "valid_from"], name: "index_handle_assignments_on_handle_id_and_valid_from", order: { valid_from: :desc }
    t.index ["handle_id"], name: "index_handle_assignments_on_handle_id", unique: true, where: "(valid_to = 'infinity'::timestamp with time zone)"
  end

  create_table "handle_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_handle_statuses_on_key", unique: true
  end

  create_table "handles", id: :string, force: :cascade do |t|
    t.timestamptz "cooldown_until", null: false
    t.datetime "created_at", null: false
    t.string "handle", null: false
    t.string "handle_status_id"
    t.boolean "is_system", default: false, null: false
    t.string "public_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cooldown_until"], name: "index_handles_on_cooldown_until"
    t.index ["handle"], name: "uniq_handles_handle_non_system", unique: true, where: "(is_system = false)"
    t.index ["handle_status_id"], name: "index_handles_on_handle_status_id"
    t.index ["is_system"], name: "index_handles_on_is_system"
    t.index ["public_id"], name: "index_handles_on_public_id", unique: true
  end

  create_table "post_review_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_post_review_statuses_on_key", unique: true
  end

  create_table "post_reviews", id: :string, force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", null: false
    t.timestamptz "decided_at"
    t.string "post_id", null: false
    t.string "post_review_status_id", null: false
    t.string "reviewer_actor_id", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "reviewer_actor_id"], name: "index_post_reviews_on_post_id_and_reviewer_actor_id", unique: true
    t.index ["post_review_status_id"], name: "index_post_reviews_on_post_review_status_id"
    t.index ["reviewer_actor_id"], name: "index_post_reviews_on_reviewer_actor_id", where: "(decided_at IS NULL)"
  end

  create_table "post_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_post_statuses_on_key", unique: true
  end

  create_table "posts", id: :string, force: :cascade do |t|
    t.string "author_avatar_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "created_by_actor_id", null: false
    t.string "post_status_id", null: false
    t.string "public_id", null: false
    t.timestamptz "published_at"
    t.string "published_by_actor_id"
    t.datetime "updated_at", null: false
    t.index ["author_avatar_id", "created_at"], name: "index_posts_on_author_avatar_id_and_created_at", order: { created_at: :desc }
    t.index ["post_status_id"], name: "index_posts_on_post_status_id"
    t.index ["public_id"], name: "index_posts_on_public_id", unique: true
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

  create_table "roles", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "key", default: "", null: false
    t.string "name", default: "", null: false
    t.uuid "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "staff_identity_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "staff_identity_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
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

  create_table "staff_identity_email_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_email_statuses_id_format"
  end

  create_table "staff_identity_emails", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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
    t.index ["otp_last_sent_at"], name: "index_staff_identity_emails_on_otp_last_sent_at"
    t.index ["staff_id"], name: "index_staff_identity_emails_on_staff_id"
    t.index ["staff_identity_email_status_id"], name: "index_staff_identity_emails_on_staff_identity_email_status_id"
    t.check_constraint "staff_identity_email_status_id IS NULL OR staff_identity_email_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_emails_staff_identity_email_status_id_format"
  end

  create_table "staff_identity_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.uuid "staff_id", null: false
    t.datetime "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
    t.index ["webauthn_id"], name: "index_staff_identity_passkeys_on_webauthn_id", unique: true
  end

  create_table "staff_identity_secret_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_secret_statuses_id_format"
  end

  create_table "staff_identity_secrets", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.datetime "last_used_at", default: -::Float::INFINITY, null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.uuid "staff_id", null: false
    t.string "staff_identity_secret_status_id", limit: 255, default: "ACTIVE", null: false
    t.datetime "updated_at", null: false
    t.integer "uses_remaining", default: 1, null: false
    t.index ["expires_at"], name: "index_staff_identity_secrets_on_expires_at"
    t.index ["staff_id"], name: "index_staff_identity_secrets_on_staff_id"
    t.index ["staff_identity_secret_status_id"], name: "idx_on_staff_identity_secret_status_id_0999b0c4ae"
    t.check_constraint "staff_identity_secret_status_id IS NULL OR staff_identity_secret_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_secrets_staff_identity_secret_status_id_94c4"
    t.check_constraint "uses_remaining >= 0", name: "chk_staff_identity_secrets_uses_remaining_non_negative"
  end

  create_table "staff_identity_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_statuses_id_format"
  end

  create_table "staff_identity_telephone_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_telephone_statuses_id_format"
  end

  create_table "staff_identity_telephones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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
    t.index ["staff_id"], name: "index_staff_identity_telephones_on_staff_id"
    t.index ["staff_identity_telephone_status_id"], name: "idx_on_staff_identity_telephone_status_id_f2b1a32f7a"
    t.check_constraint "staff_identity_telephone_status_id IS NULL OR staff_identity_telephone_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_telephones_staff_identity_telephone_status_i"
  end

  create_table "staff_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", default: "", null: false
    t.string "name", default: "", null: false
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.uuid "staff_id", null: false
    t.string "transports", default: "", null: false
    t.datetime "updated_at", null: false
    t.string "user_handle", default: "", null: false
    t.index ["external_id"], name: "index_staff_passkeys_on_external_id"
    t.index ["staff_id"], name: "index_staff_passkeys_on_staff_id"
  end

  create_table "staff_recovery_codes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in", null: false
    t.string "recovery_code_digest", default: "", null: false
    t.uuid "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staffs", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "staff_identity_status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id", default: "", null: false
    t.datetime "withdrawn_at", default: ::Float::INFINITY
    t.index ["public_id"], name: "index_staffs_on_public_id", unique: true
    t.index ["staff_identity_status_id"], name: "index_staffs_on_staff_identity_status_id"
    t.index ["withdrawn_at"], name: "index_staffs_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
    t.check_constraint "staff_identity_status_id IS NULL OR staff_identity_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staffs_staff_identity_status_id_format"
  end

  create_table "user_identity_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "user_identity_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
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

  create_table "user_identity_email_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_email_statuses_id_format"
  end

  create_table "user_identity_emails", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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
    t.string "user_identity_email_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.index "lower((address)::text)", name: "index_user_identity_emails_on_lower_address", unique: true
    t.index ["otp_last_sent_at"], name: "index_user_identity_emails_on_otp_last_sent_at"
    t.index ["user_id"], name: "index_user_identity_emails_on_user_id"
    t.index ["user_identity_email_status_id"], name: "index_user_identity_emails_on_user_identity_email_status_id"
    t.check_constraint "user_identity_email_status_id IS NULL OR user_identity_email_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_emails_user_identity_email_status_id_format"
  end

  create_table "user_identity_one_time_password_statuses", id: :string, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_one_time_password_statuses_id_format"
  end

  create_table "user_identity_one_time_passwords", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_otp_at", default: -::Float::INFINITY, null: false
    t.string "private_key", limit: 1024, default: "", null: false
    t.datetime "updated_at", null: false
    t.binary "user_id", null: false
    t.string "user_identity_one_time_password_status_id", default: "NONE", null: false
    t.index ["user_identity_one_time_password_status_id"], name: "idx_on_user_identity_one_time_password_status_id_01264db86c"
    t.check_constraint "user_identity_one_time_password_status_id IS NULL OR user_identity_one_time_password_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_one_time_passwords_user_identity_one_time_pas"
  end

  create_table "user_identity_passkey_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_passkey_statuses_id_format"
  end

  create_table "user_identity_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_passkey_status_id", limit: 255, default: "ACTIVE", null: false
    t.string "webauthn_id", default: "", null: false
    t.index ["user_id"], name: "index_user_identity_passkeys_on_user_id"
    t.index ["user_identity_passkey_status_id"], name: "idx_on_user_identity_passkey_status_id_f979a7d699"
    t.index ["webauthn_id"], name: "index_user_identity_passkeys_on_webauthn_id", unique: true
    t.check_constraint "user_identity_passkey_status_id IS NULL OR user_identity_passkey_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_passkeys_user_identity_passkey_status_id_0993"
  end

  create_table "user_identity_secret_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_secret_statuses_id_format"
  end

  create_table "user_identity_secrets", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.datetime "last_used_at", default: -::Float::INFINITY, null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_secret_status_id", limit: 255, default: "ACTIVE", null: false
    t.integer "uses_remaining", default: 1, null: false
    t.index ["expires_at"], name: "index_user_identity_secrets_on_expires_at"
    t.index ["user_id"], name: "index_user_identity_secrets_on_user_id"
    t.index ["user_identity_secret_status_id"], name: "index_user_identity_secrets_on_user_identity_secret_status_id"
    t.check_constraint "user_identity_secret_status_id IS NULL OR user_identity_secret_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_secrets_user_identity_secret_status_id_format"
    t.check_constraint "uses_remaining >= 0", name: "chk_user_identity_secrets_uses_remaining_non_negative"
  end

  create_table "user_identity_social_apple_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_apple_statuses_id_format"
  end

  create_table "user_identity_social_apples", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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
    t.index ["expires_at"], name: "index_user_identity_social_apples_on_expires_at"
    t.index ["uid", "provider"], name: "index_user_identity_social_apples_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_user_identity_social_apples_on_user_id_unique", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_identity_social_apple_status_id"], name: "idx_on_user_identity_social_apple_status_id_d1764af59f"
    t.check_constraint "user_identity_social_apple_status_id IS NULL OR user_identity_social_apple_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_apples_user_identity_social_apple_stat"
  end

  create_table "user_identity_social_google_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_google_statuses_id_format"
  end

  create_table "user_identity_social_googles", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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
    t.index ["expires_at"], name: "index_user_identity_social_googles_on_expires_at"
    t.index ["uid", "provider"], name: "index_user_identity_social_googles_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_user_identity_social_googles_on_user_id_unique", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_identity_social_google_status_id"], name: "idx_on_user_identity_social_google_status_id_7bdb8753df"
    t.check_constraint "user_identity_social_google_status_id IS NULL OR user_identity_social_google_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_social_googles_user_identity_social_google_st"
  end

  create_table "user_identity_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_statuses_id_format"
  end

  create_table "user_identity_telephone_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.index "lower((id)::text)", name: "index_user_identity_telephone_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_telephone_statuses_id_format"
  end

  create_table "user_identity_telephones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.string "number", default: "", null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "user_identity_telephone_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.index ["user_id"], name: "index_user_identity_telephones_on_user_id"
    t.index ["user_identity_telephone_status_id"], name: "idx_on_user_identity_telephone_status_id_a15207191e"
    t.check_constraint "user_identity_telephone_status_id IS NULL OR user_identity_telephone_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_telephones_user_identity_telephone_status_id_"
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

  create_table "user_passkeys", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", default: "", null: false
    t.string "name", default: "", null: false
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.string "transports", default: "", null: false
    t.datetime "updated_at", null: false
    t.string "user_handle", default: "", null: false
    t.uuid "user_id", null: false
    t.index ["external_id"], name: "index_user_passkeys_on_external_id"
    t.index ["user_id"], name: "index_user_passkeys_on_user_id"
  end

  create_table "user_workspaces", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.uuid "workspace_id", null: false
    t.index ["user_id"], name: "index_user_workspaces_on_user_id"
    t.index ["workspace_id"], name: "index_user_workspaces_on_workspace_id"
  end

  create_table "users", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "updated_at", null: false
    t.string "user_identity_status_id", limit: 255, default: "NONE", null: false
    t.string "webauthn_id", default: "", null: false
    t.datetime "withdrawn_at", default: ::Float::INFINITY
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["user_identity_status_id"], name: "index_users_on_user_identity_status_id"
    t.index ["withdrawn_at"], name: "index_users_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
    t.check_constraint "user_identity_status_id IS NULL OR user_identity_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_users_user_identity_status_id_format"
  end

  create_table "workspaces", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain", default: "", null: false
    t.string "name", default: "", null: false
    t.uuid "parent_organization", default: "00000000-0000-0000-0000-000000000000", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_workspaces_on_domain", unique: true, where: "(domain IS NOT NULL)"
    t.index ["parent_organization"], name: "index_workspaces_on_parent_organization"
  end

  add_foreign_key "apple_auths", "users"
  add_foreign_key "avatar_memberships", "avatar_membership_statuses"
  add_foreign_key "avatar_memberships", "avatars"
  add_foreign_key "avatar_monikers", "avatar_moniker_statuses"
  add_foreign_key "avatar_monikers", "avatars"
  add_foreign_key "avatar_ownership_periods", "avatar_ownership_statuses"
  add_foreign_key "avatar_ownership_periods", "avatars"
  add_foreign_key "avatar_role_permissions", "avatar_permissions"
  add_foreign_key "avatar_role_permissions", "avatar_roles"
  add_foreign_key "avatars", "avatar_capabilities", column: "capability_id"
  add_foreign_key "avatars", "handles", column: "active_handle_id"
  add_foreign_key "google_auths", "users"
  add_foreign_key "handle_assignments", "avatars"
  add_foreign_key "handle_assignments", "handle_assignment_statuses"
  add_foreign_key "handle_assignments", "handles"
  add_foreign_key "handles", "handle_statuses"
  add_foreign_key "post_reviews", "post_review_statuses"
  add_foreign_key "post_reviews", "posts"
  add_foreign_key "posts", "avatars", column: "author_avatar_id"
  add_foreign_key "posts", "post_statuses"
  add_foreign_key "role_assignments", "roles"
  add_foreign_key "role_assignments", "staffs", on_delete: :cascade
  add_foreign_key "role_assignments", "users", on_delete: :cascade
  add_foreign_key "roles", "workspaces", column: "organization_id"
  add_foreign_key "staff_identity_audits", "staff_identity_audit_levels", column: "level_id", name: "fk_staff_audits_level", on_delete: :restrict
  add_foreign_key "staff_identity_emails", "staff_identity_email_statuses"
  add_foreign_key "staff_identity_emails", "staffs"
  add_foreign_key "staff_identity_passkeys", "staffs"
  add_foreign_key "staff_identity_secrets", "staff_identity_secret_statuses"
  add_foreign_key "staff_identity_secrets", "staffs"
  add_foreign_key "staff_identity_telephones", "staff_identity_telephone_statuses"
  add_foreign_key "staff_identity_telephones", "staffs"
  add_foreign_key "staff_passkeys", "staffs"
  add_foreign_key "staff_recovery_codes", "staffs"
  add_foreign_key "staffs", "staff_identity_statuses"
  add_foreign_key "user_identity_audits", "user_identity_audit_events", column: "event_id"
  add_foreign_key "user_identity_emails", "user_identity_email_statuses"
  add_foreign_key "user_identity_emails", "users"
  add_foreign_key "user_identity_one_time_passwords", "user_identity_one_time_password_statuses"
  add_foreign_key "user_identity_passkeys", "user_identity_passkey_statuses"
  add_foreign_key "user_identity_passkeys", "users"
  add_foreign_key "user_identity_secrets", "user_identity_secret_statuses"
  add_foreign_key "user_identity_secrets", "users"
  add_foreign_key "user_identity_social_apples", "user_identity_social_apple_statuses"
  add_foreign_key "user_identity_social_apples", "users"
  add_foreign_key "user_identity_social_googles", "user_identity_social_google_statuses"
  add_foreign_key "user_identity_social_googles", "users"
  add_foreign_key "user_identity_telephones", "user_identity_telephone_statuses"
  add_foreign_key "user_identity_telephones", "users"
  add_foreign_key "user_memberships", "users"
  add_foreign_key "user_memberships", "workspaces"
  add_foreign_key "user_passkeys", "users"
  add_foreign_key "user_workspaces", "users"
  add_foreign_key "user_workspaces", "workspaces"
  add_foreign_key "users", "user_identity_statuses"
  add_foreign_key "workspaces", "workspaces", column: "parent_organization"
end
