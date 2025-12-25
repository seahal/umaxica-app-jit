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

ActiveRecord::Schema[8.2].define(version: 2025_12_25_012748) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "app_contact_audit_events", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contact_audit_events_id_format"
  end

  create_table "app_contact_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_app_contact_audit_levels_on_lower_id", unique: true
  end

  create_table "app_contact_categories", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_id", limit: 255, default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_app_contact_categories_on_parent_id"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contact_categories_id_format"
  end

  create_table "app_contact_emails", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "app_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "token_digest", limit: 255, default: "", null: false
    t.timestamptz "token_expires_at", default: -::Float::INFINITY, null: false
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255, default: "", null: false
    t.timestamptz "verifier_expires_at", default: -::Float::INFINITY, null: false
    t.index ["app_contact_id"], name: "index_app_contact_emails_on_app_contact_id"
    t.index ["email_address"], name: "index_app_contact_emails_on_email_address"
    t.index ["expires_at"], name: "index_app_contact_emails_on_expires_at"
    t.index ["verifier_expires_at"], name: "index_app_contact_emails_on_verifier_expires_at"
  end

  create_table "app_contact_histories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.uuid "app_contact_id", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.string "level_id", default: "NONE", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_contact_histories_on_actor_type_and_actor_id"
    t.index ["app_contact_id"], name: "index_app_contact_histories_on_app_contact_id"
    t.index ["level_id"], name: "index_app_contact_histories_on_level_id"
    t.index ["parent_id"], name: "index_app_contact_histories_on_parent_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contact_histories_event_id_format"
  end

  create_table "app_contact_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_title", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contact_statuses_id_format"
  end

  create_table "app_contact_telephones", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "app_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255, default: "", null: false
    t.timestamptz "verifier_expires_at", default: -::Float::INFINITY, null: false
    t.index ["app_contact_id"], name: "index_app_contact_telephones_on_app_contact_id"
    t.index ["expires_at"], name: "index_app_contact_telephones_on_expires_at"
    t.index ["telephone_number"], name: "index_app_contact_telephones_on_telephone_number"
    t.index ["verifier_expires_at"], name: "index_app_contact_telephones_on_verifier_expires_at"
  end

  create_table "app_contact_topics", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "app_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest", limit: 255, default: "", null: false
    t.timestamptz "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.datetime "updated_at", null: false
    t.index ["app_contact_id"], name: "index_app_contact_topics_on_app_contact_id"
    t.index ["expires_at"], name: "index_app_contact_topics_on_expires_at"
    t.index ["public_id"], name: "index_app_contact_topics_on_public_id"
  end

  create_table "app_contacts", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "contact_category_title", limit: 255, default: "APPLICATION_INQUIRY", null: false
    t.string "contact_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest", limit: 255, default: "", null: false
    t.timestamptz "token_expires_at", default: -::Float::INFINITY, null: false
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_category_title"], name: "index_app_contacts_on_contact_category_title"
    t.index ["contact_status_id"], name: "index_app_contacts_on_contact_status_id"
    t.index ["public_id"], name: "index_app_contacts_on_public_id"
    t.index ["token"], name: "index_app_contacts_on_token"
    t.index ["token_digest"], name: "index_app_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_app_contacts_on_token_expires_at"
    t.check_constraint "contact_category_title IS NULL OR contact_category_title::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contacts_contact_category_title_format"
    t.check_constraint "contact_status_id IS NULL OR contact_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contacts_contact_status_id_format"
  end

  create_table "com_contact_audit_events", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_contact_audit_events_id_format"
  end

  create_table "com_contact_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_com_contact_audit_levels_on_lower_id", unique: true
  end

  create_table "com_contact_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.uuid "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.string "level_id", default: "NONE", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_contact_audits_on_actor_type_and_actor_id"
    t.index ["com_contact_id"], name: "index_com_contact_audits_on_com_contact_id"
    t.index ["level_id"], name: "index_com_contact_audits_on_level_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_contact_audits_event_id_format"
  end

  create_table "com_contact_categories", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_id", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_com_contact_categories_on_parent_id"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_contact_categories_id_format"
  end

  create_table "com_contact_emails", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "hotp_counter", default: 0, null: false
    t.string "hotp_secret", default: "", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "token_digest", limit: 255, default: "", null: false
    t.timestamptz "token_expires_at", default: -::Float::INFINITY, null: false
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 5, null: false
    t.string "verifier_digest", limit: 255, default: "", null: false
    t.timestamptz "verifier_expires_at", default: -::Float::INFINITY, null: false
    t.index ["com_contact_id"], name: "index_com_contact_emails_on_com_contact_id"
    t.index ["email_address"], name: "index_com_contact_emails_on_email_address"
    t.index ["expires_at"], name: "index_com_contact_emails_on_expires_at"
    t.index ["verifier_expires_at"], name: "index_com_contact_emails_on_verifier_expires_at"
  end

  create_table "com_contact_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_id", limit: 255, default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.index ["parent_id"], name: "index_com_contact_statuses_on_parent_id"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_contact_statuses_id_format"
  end

  create_table "com_contact_telephones", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "hotp_counter", default: 0, null: false
    t.string "hotp_secret", default: "", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255, default: "", null: false
    t.timestamptz "verifier_expires_at", default: -::Float::INFINITY, null: false
    t.index ["com_contact_id"], name: "index_com_contact_telephones_on_com_contact_id"
    t.index ["expires_at"], name: "index_com_contact_telephones_on_expires_at"
    t.index ["telephone_number"], name: "index_com_contact_telephones_on_telephone_number"
    t.index ["verifier_expires_at"], name: "index_com_contact_telephones_on_verifier_expires_at"
  end

  create_table "com_contact_topics", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.text "description", default: "", null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest", limit: 255, default: "", null: false
    t.timestamptz "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["com_contact_id"], name: "index_com_contact_topics_on_com_contact_id"
    t.index ["expires_at"], name: "index_com_contact_topics_on_expires_at"
    t.index ["public_id"], name: "index_com_contact_topics_on_public_id"
  end

  create_table "com_contacts", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "contact_category_title", limit: 255, default: "SECURITY_ISSUE", null: false
    t.string "contact_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest", limit: 255, default: "", null: false
    t.timestamptz "token_expires_at", default: -::Float::INFINITY, null: false
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_category_title"], name: "index_com_contacts_on_contact_category_title"
    t.index ["contact_status_id"], name: "index_com_contacts_on_contact_status_id"
    t.index ["public_id"], name: "index_com_contacts_on_public_id"
    t.index ["token"], name: "index_com_contacts_on_token"
    t.index ["token_digest"], name: "index_com_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_com_contacts_on_token_expires_at"
    t.check_constraint "contact_category_title IS NULL OR contact_category_title::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_contacts_contact_category_title_format"
    t.check_constraint "contact_status_id IS NULL OR contact_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_contacts_contact_status_id_format"
  end

  create_table "org_contact_audit_events", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_contact_audit_events_id_format"
  end

  create_table "org_contact_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_org_contact_audit_levels_on_lower_id", unique: true
  end

  create_table "org_contact_categories", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_id", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_org_contact_categories_on_parent_id"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_contact_categories_id_format"
  end

  create_table "org_contact_emails", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.uuid "org_contact_id", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "token_digest", limit: 255, default: "", null: false
    t.timestamptz "token_expires_at", default: -::Float::INFINITY, null: false
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255, default: "", null: false
    t.timestamptz "verifier_expires_at", default: -::Float::INFINITY, null: false
    t.index ["email_address"], name: "index_org_contact_emails_on_email_address"
    t.index ["expires_at"], name: "index_org_contact_emails_on_expires_at"
    t.index ["org_contact_id"], name: "index_org_contact_emails_on_org_contact_id"
    t.index ["verifier_expires_at"], name: "index_org_contact_emails_on_verifier_expires_at"
  end

  create_table "org_contact_histories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.string "level_id", default: "NONE", null: false
    t.uuid "org_contact_id", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_contact_histories_on_actor_type_and_actor_id"
    t.index ["level_id"], name: "index_org_contact_histories_on_level_id"
    t.index ["org_contact_id"], name: "index_org_contact_histories_on_org_contact_id"
    t.index ["parent_id"], name: "index_org_contact_histories_on_parent_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_contact_histories_event_id_format"
  end

  create_table "org_contact_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_id", limit: 255, default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.index ["parent_id"], name: "index_org_contact_statuses_on_parent_id"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_contact_statuses_id_format"
  end

  create_table "org_contact_telephones", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.uuid "org_contact_id", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.datetime "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255, default: "", null: false
    t.timestamptz "verifier_expires_at", default: -::Float::INFINITY, null: false
    t.index ["expires_at"], name: "index_org_contact_telephones_on_expires_at"
    t.index ["org_contact_id"], name: "index_org_contact_telephones_on_org_contact_id"
    t.index ["telephone_number"], name: "index_org_contact_telephones_on_telephone_number"
    t.index ["verifier_expires_at"], name: "index_org_contact_telephones_on_verifier_expires_at"
  end

  create_table "org_contact_topics", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.uuid "org_contact_id", null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest", limit: 255, default: "", null: false
    t.timestamptz "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_org_contact_topics_on_expires_at"
    t.index ["org_contact_id"], name: "index_org_contact_topics_on_org_contact_id"
    t.index ["public_id"], name: "index_org_contact_topics_on_public_id"
  end

  create_table "org_contacts", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "contact_category_title", limit: 255, default: "ORGANIZATION_INQUIRY", null: false
    t.string "contact_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest", limit: 255, default: "", null: false
    t.timestamptz "token_expires_at", default: -::Float::INFINITY, null: false
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_category_title"], name: "index_org_contacts_on_contact_category_title"
    t.index ["contact_status_id"], name: "index_org_contacts_on_contact_status_id"
    t.index ["public_id"], name: "index_org_contacts_on_public_id"
    t.index ["token"], name: "index_org_contacts_on_token"
    t.index ["token_digest"], name: "index_org_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_org_contacts_on_token_expires_at"
    t.check_constraint "contact_category_title IS NULL OR contact_category_title::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_contacts_contact_category_title_format"
    t.check_constraint "contact_status_id IS NULL OR contact_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_contacts_contact_status_id_format"
  end

  add_foreign_key "app_contact_emails", "app_contacts"
  add_foreign_key "app_contact_histories", "app_contact_audit_events", column: "event_id"
  add_foreign_key "app_contact_histories", "app_contact_audit_levels", column: "level_id"
  add_foreign_key "app_contact_histories", "app_contacts"
  add_foreign_key "app_contact_telephones", "app_contacts"
  add_foreign_key "app_contact_topics", "app_contacts"
  add_foreign_key "app_contacts", "app_contact_categories", column: "contact_category_title"
  add_foreign_key "app_contacts", "app_contact_statuses", column: "contact_status_id"
  add_foreign_key "com_contact_audits", "com_contact_audit_events", column: "event_id"
  add_foreign_key "com_contact_audits", "com_contact_audit_levels", column: "level_id"
  add_foreign_key "com_contact_audits", "com_contacts"
  add_foreign_key "com_contact_topics", "com_contacts"
  add_foreign_key "com_contacts", "com_contact_categories", column: "contact_category_title"
  add_foreign_key "com_contacts", "com_contact_statuses", column: "contact_status_id"
  add_foreign_key "org_contact_emails", "org_contacts"
  add_foreign_key "org_contact_histories", "org_contact_audit_events", column: "event_id"
  add_foreign_key "org_contact_histories", "org_contact_audit_levels", column: "level_id"
  add_foreign_key "org_contact_histories", "org_contacts"
  add_foreign_key "org_contact_telephones", "org_contacts"
  add_foreign_key "org_contact_topics", "org_contacts"
  add_foreign_key "org_contacts", "org_contact_categories", column: "contact_category_title"
  add_foreign_key "org_contacts", "org_contact_statuses", column: "contact_status_id"
end
