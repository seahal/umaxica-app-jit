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

ActiveRecord::Schema[8.2].define(version: 2025_12_25_183101) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", force: :cascade do |t|
    t.bigint "accountable_id", null: false
    t.string "accountable_type", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
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
    t.bigint "app_contact_id", null: false
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

  create_table "app_contact_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "description", limit: 255, default: "", null: false
    t.string "parent_title", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_contact_statuses_id_format"
  end

  create_table "app_contact_telephones", id: :string, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "app_contact_id", null: false
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

  create_table "app_contact_topics", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "app_contact_id", null: false
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

  create_table "app_contacts", force: :cascade do |t|
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

  create_table "apple_auths", force: :cascade do |t|
    t.text "access_token", null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.datetime "expires_at", null: false
    t.string "name", default: "", null: false
    t.string "provider", default: "", null: false
    t.text "refresh_token", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_apple_auths_on_user_id"
  end

  create_table "area_domain_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_domain_occurrences_on_area_occurrence_id"
    t.index ["domain_occurrence_id"], name: "index_area_domain_occurrences_on_domain_occurrence_id"
  end

  create_table "area_email_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.bigint "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_email_occurrences_on_area_occurrence_id"
    t.index ["email_occurrence_id"], name: "index_area_email_occurrences_on_email_occurrence_id"
  end

  create_table "area_ip_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.bigint "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_ip_occurrences_on_area_occurrence_id"
    t.index ["ip_occurrence_id"], name: "index_area_ip_occurrences_on_ip_occurrence_id"
  end

  create_table "area_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_area_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_area_occurrence_statuses_id_format"
  end

  create_table "area_occurrences", force: :cascade do |t|
    t.string "body", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_area_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_area_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_area_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_area_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_area_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_area_occurrences_public_id_format"
  end

  create_table "area_staff_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.bigint "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_staff_occurrences_on_area_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_area_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "area_telephone_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_telephone_occurrences_on_area_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_area_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "area_user_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.index ["area_occurrence_id"], name: "index_area_user_occurrences_on_area_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_area_user_occurrences_on_user_occurrence_id"
  end

  create_table "area_zip_occurrences", force: :cascade do |t|
    t.bigint "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["area_occurrence_id"], name: "index_area_zip_occurrences_on_area_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_area_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "com_contact_audits", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.string "actor_type", default: "", null: false
    t.bigint "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.string "level_id", default: "NONE", null: false
    t.bigint "parent_id", default: 0, null: false
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
    t.bigint "com_contact_id", null: false
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
    t.bigint "com_contact_id", null: false
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

  create_table "com_contact_topics", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "com_contact_id", null: false
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

  create_table "com_contacts", force: :cascade do |t|
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

  create_table "domain_email_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.bigint "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_email_occurrences_on_domain_occurrence_id"
    t.index ["email_occurrence_id"], name: "index_domain_email_occurrences_on_email_occurrence_id"
  end

  create_table "domain_ip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.bigint "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_ip_occurrences_on_domain_occurrence_id"
    t.index ["ip_occurrence_id"], name: "index_domain_ip_occurrences_on_ip_occurrence_id"
  end

  create_table "domain_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_domain_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_domain_occurrence_statuses_id_format"
  end

  create_table "domain_occurrences", force: :cascade do |t|
    t.string "body", limit: 253, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_domain_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_domain_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_domain_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_domain_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_domain_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_domain_occurrences_public_id_format"
  end

  create_table "domain_staff_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.bigint "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_staff_occurrences_on_domain_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_domain_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "domain_telephone_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_telephone_occurrences_on_domain_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_domain_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "domain_user_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_user_occurrences_on_domain_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_domain_user_occurrences_on_user_occurrence_id"
  end

  create_table "domain_zip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_zip_occurrences_on_domain_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_domain_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "email_ip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_occurrence_id", null: false
    t.bigint "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_occurrence_id"], name: "index_email_ip_occurrences_on_email_occurrence_id"
    t.index ["ip_occurrence_id"], name: "index_email_ip_occurrences_on_ip_occurrence_id"
  end

  create_table "email_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_email_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_email_occurrence_statuses_id_format"
  end

  create_table "email_occurrences", force: :cascade do |t|
    t.string "body", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_email_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_email_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_email_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_email_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_email_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_email_occurrences_public_id_format"
  end

  create_table "email_staff_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_occurrence_id", null: false
    t.bigint "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_occurrence_id"], name: "index_email_staff_occurrences_on_email_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_email_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "email_telephone_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_occurrence_id", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_occurrence_id"], name: "index_email_telephone_occurrences_on_email_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_email_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "email_user_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.index ["email_occurrence_id"], name: "index_email_user_occurrences_on_email_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_email_user_occurrences_on_user_occurrence_id"
  end

  create_table "email_zip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["email_occurrence_id"], name: "index_email_zip_occurrences_on_email_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_email_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "google_auths", force: :cascade do |t|
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
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_google_auths_on_user_id"
  end

  create_table "ip_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_ip_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_ip_occurrence_statuses_id_format"
  end

  create_table "ip_occurrences", force: :cascade do |t|
    t.string "body", limit: 64, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_ip_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_ip_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_ip_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_ip_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_ip_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_ip_occurrences_public_id_format"
  end

  create_table "ip_staff_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ip_occurrence_id", null: false
    t.bigint "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_staff_occurrences_on_ip_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_ip_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "ip_telephone_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ip_occurrence_id", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_telephone_occurrences_on_ip_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_ip_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "ip_user_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_user_occurrences_on_ip_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_ip_user_occurrences_on_user_occurrence_id"
  end

  create_table "ip_zip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_zip_occurrences_on_ip_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_ip_zip_occurrences_on_zip_occurrence_id"
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
    t.bigint "org_contact_id", null: false
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
    t.bigint "org_contact_id", null: false
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

  create_table "org_contact_topics", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.bigint "org_contact_id", null: false
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

  create_table "org_contacts", force: :cascade do |t|
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

  create_table "post_versions", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.string "permalink", limit: 200, null: false
    t.string "post_id", null: false
    t.string "public_id", default: "", null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["post_id", "created_at"], name: "index_post_versions_on_post_id_and_created_at", order: { created_at: :desc }
    t.index ["public_id"], name: "index_post_versions_on_public_id", unique: true
  end

  create_table "role_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.bigint "staff_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["role_id"], name: "index_role_assignments_on_role_id"
    t.index ["staff_id", "role_id"], name: "index_role_assignments_on_staff_role", unique: true
    t.index ["user_id", "role_id"], name: "index_role_assignments_on_user_role", unique: true
    t.check_constraint "user_id IS NOT NULL AND staff_id IS NULL OR staff_id IS NOT NULL AND user_id IS NULL", name: "role_assignments_user_or_staff_check"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.string "key", default: "", null: false
    t.string "name", default: "", null: false
    t.bigint "organization_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "staff_identity_audit_events", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audit_levels", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audits", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.string "event_id", default: "NONE", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.text "previous_value"
    t.bigint "staff_id", null: false
    t.bigint "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_staff_identity_audits_on_event_id"
    t.index ["level_id"], name: "index_staff_identity_audits_on_level_id"
    t.index ["staff_id"], name: "index_staff_identity_audits_on_staff_id"
  end

  create_table "staff_identity_email_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_email_statuses_id_format"
  end

  create_table "staff_identity_emails", force: :cascade do |t|
    t.string "address", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.datetime "otp_last_sent_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.bigint "staff_id", null: false
    t.string "staff_identity_email_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.datetime "updated_at", null: false
    t.index ["otp_last_sent_at"], name: "index_staff_identity_emails_on_otp_last_sent_at"
    t.index ["staff_id"], name: "index_staff_identity_emails_on_staff_id"
    t.index ["staff_identity_email_status_id"], name: "index_staff_identity_emails_on_staff_identity_email_status_id"
    t.check_constraint "staff_identity_email_status_id IS NULL OR staff_identity_email_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_emails_staff_identity_email_status_id_format"
  end

  create_table "staff_identity_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.bigint "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.binary "webauthn_id", null: false
    t.index ["staff_id"], name: "index_staff_identity_passkeys_on_staff_id"
    t.index ["webauthn_id"], name: "index_staff_identity_passkeys_on_webauthn_id", unique: true
  end

  create_table "staff_identity_secret_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_secret_statuses_id_format"
  end

  create_table "staff_identity_secrets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.datetime "last_used_at", default: -::Float::INFINITY, null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.bigint "staff_id", null: false
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

  create_table "staff_identity_telephones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.string "number", default: "", null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.bigint "staff_id", null: false
    t.string "staff_identity_telephone_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_identity_telephones_on_staff_id"
    t.index ["staff_identity_telephone_status_id"], name: "idx_on_staff_identity_telephone_status_id_f2b1a32f7a"
    t.check_constraint "staff_identity_telephone_status_id IS NULL OR staff_identity_telephone_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_identity_telephones_staff_identity_telephone_status_i"
  end

  create_table "staff_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", default: "", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", default: "000000000000000000000", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_staff_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_occurrence_statuses_id_format"
  end

  create_table "staff_occurrences", force: :cascade do |t|
    t.string "body", limit: 36, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_staff_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_staff_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_staff_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_staff_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_staff_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_staff_occurrences_public_id_format"
  end

  create_table "staff_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", default: "", null: false
    t.string "name", default: "", null: false
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.bigint "staff_id", null: false
    t.string "transports", default: "", null: false
    t.datetime "updated_at", null: false
    t.string "user_handle", default: "", null: false
    t.index ["external_id"], name: "index_staff_passkeys_on_external_id"
    t.index ["staff_id"], name: "index_staff_passkeys_on_staff_id"
  end

  create_table "staff_recovery_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_in", null: false
    t.string "recovery_code_digest", default: "", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_recovery_codes_on_staff_id"
  end

  create_table "staff_telephone_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "staff_occurrence_id", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_occurrence_id"], name: "index_staff_telephone_occurrences_on_staff_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_staff_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "staff_token_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text = ''::text OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_token_statuses_id_format"
  end

  create_table "staff_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.datetime "revoked_at"
    t.datetime "rotated_at"
    t.bigint "staff_id", null: false
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

  create_table "staff_user_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.index ["staff_occurrence_id"], name: "index_staff_user_occurrences_on_staff_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_staff_user_occurrences_on_user_occurrence_id"
  end

  create_table "staff_zip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["staff_occurrence_id"], name: "index_staff_zip_occurrences_on_staff_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_staff_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 255, default: ""
    t.string "staff_identity_status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.string "webauthn_id", default: "", null: false
    t.datetime "withdrawn_at", default: ::Float::INFINITY
    t.index ["public_id"], name: "index_staffs_on_public_id", unique: true
    t.index ["staff_identity_status_id"], name: "index_staffs_on_staff_identity_status_id"
    t.index ["withdrawn_at"], name: "index_staffs_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
    t.check_constraint "staff_identity_status_id IS NULL OR staff_identity_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staffs_staff_identity_status_id_format"
  end

  create_table "telephone_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_telephone_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_telephone_occurrence_statuses_id_format"
  end

  create_table "telephone_occurrences", force: :cascade do |t|
    t.string "body", limit: 32, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_telephone_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_telephone_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_telephone_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_telephone_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_telephone_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_telephone_occurrences_public_id_format"
  end

  create_table "telephone_user_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.index ["telephone_occurrence_id"], name: "index_telephone_user_occurrences_on_telephone_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_telephone_user_occurrences_on_user_occurrence_id"
  end

  create_table "telephone_zip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["telephone_occurrence_id"], name: "index_telephone_zip_occurrences_on_telephone_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_telephone_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "user_identity_audit_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audit_levels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audits", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", default: 0, null: false
    t.string "ip_address", default: "", null: false
    t.bigint "level_id", default: 0, null: false
    t.text "previous_value"
    t.bigint "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_user_identity_audits_on_event_id"
    t.index ["level_id"], name: "index_user_identity_audits_on_level_id"
    t.index ["user_id"], name: "index_user_identity_audits_on_user_id"
  end

  create_table "user_identity_email_statuses", id: { type: :string, limit: 255, default: "UNVERIFIED" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_email_statuses_id_format"
  end

  create_table "user_identity_emails", force: :cascade do |t|
    t.string "address", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.datetime "otp_last_sent_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "user_identity_email_status_id", limit: 255, default: "UNVERIFIED", null: false
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

  create_table "user_identity_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.bigint "external_id", null: false
    t.text "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
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

  create_table "user_identity_secrets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.datetime "last_used_at", default: -::Float::INFINITY, null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
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

  create_table "user_identity_social_apples", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.integer "expires_at", null: false
    t.string "image", default: "", null: false
    t.string "provider", default: "apple", null: false
    t.string "refresh_token", default: "", null: false
    t.string "token", default: "", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
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

  create_table "user_identity_social_googles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.integer "expires_at", null: false
    t.string "image", default: "", null: false
    t.string "provider", default: "google_oauth2", null: false
    t.string "refresh_token", default: "", null: false
    t.string "token", default: "", null: false
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
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
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_telephone_statuses_id_format"
  end

  create_table "user_identity_telephones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at", default: -::Float::INFINITY, null: false
    t.string "number", default: "", null: false
    t.integer "otp_attempts_count", default: 0, null: false
    t.text "otp_counter", default: "", null: false
    t.datetime "otp_expires_at", default: -::Float::INFINITY, null: false
    t.string "otp_private_key", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "user_identity_telephone_status_id", limit: 255, default: "UNVERIFIED", null: false
    t.index ["user_id"], name: "index_user_identity_telephones_on_user_id"
    t.index ["user_identity_telephone_status_id"], name: "idx_on_user_identity_telephone_status_id_a15207191e"
    t.check_constraint "user_identity_telephone_status_id IS NULL OR user_identity_telephone_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_identity_telephones_user_identity_telephone_status_id_"
  end

  create_table "user_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "left_at", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "workspace_id", null: false
    t.index ["user_id", "workspace_id"], name: "index_user_memberships_on_user_id_and_workspace_id", unique: true
    t.index ["workspace_id"], name: "index_user_memberships_on_workspace_id"
  end

  create_table "user_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", default: "", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
  end

  create_table "user_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", default: "000000000000000000000", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
  end

  create_table "user_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_user_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_occurrence_statuses_id_format"
  end

  create_table "user_occurrences", force: :cascade do |t|
    t.string "body", limit: 36, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_user_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_user_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_user_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_user_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_user_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_user_occurrences_public_id_format"
  end

  create_table "user_passkeys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", default: "", null: false
    t.string "name", default: "", null: false
    t.text "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.string "transports", default: "", null: false
    t.datetime "updated_at", null: false
    t.string "user_handle", default: "", null: false
    t.bigint "user_id", null: false
    t.index ["external_id"], name: "index_user_passkeys_on_external_id"
    t.index ["user_id"], name: "index_user_passkeys_on_user_id"
  end

  create_table "user_token_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text = ''::text OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_token_statuses_id_format"
  end

  create_table "user_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "public_id", limit: 21, default: "", null: false
    t.datetime "refresh_expires_at", null: false
    t.binary "refresh_token_digest"
    t.datetime "revoked_at"
    t.datetime "rotated_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "user_token_status_id", default: "NONE", null: false
    t.index ["public_id"], name: "index_user_tokens_on_public_id", unique: true
    t.index ["refresh_expires_at"], name: "index_user_tokens_on_refresh_expires_at"
    t.index ["refresh_token_digest"], name: "index_user_tokens_on_refresh_token_digest", unique: true
    t.index ["revoked_at"], name: "index_user_tokens_on_revoked_at"
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
    t.index ["user_token_status_id"], name: "index_user_tokens_on_user_token_status_id"
    t.check_constraint "user_token_status_id IS NULL OR user_token_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_tokens_user_token_status_id_format"
  end

  create_table "user_workspaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "workspace_id", null: false
    t.index ["user_id"], name: "index_user_workspaces_on_user_id"
    t.index ["workspace_id"], name: "index_user_workspaces_on_workspace_id"
  end

  create_table "user_zip_occurrences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_occurrence_id", null: false
    t.bigint "zip_occurrence_id", null: false
    t.index ["user_occurrence_id"], name: "index_user_zip_occurrences_on_user_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_user_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "public_id", limit: 255, default: ""
    t.datetime "updated_at", null: false
    t.string "user_identity_status_id", limit: 255, default: "NONE", null: false
    t.string "webauthn_id", default: "", null: false
    t.datetime "withdrawn_at", default: ::Float::INFINITY
    t.index ["public_id"], name: "index_users_on_public_id", unique: true
    t.index ["user_identity_status_id"], name: "index_users_on_user_identity_status_id"
    t.index ["withdrawn_at"], name: "index_users_on_withdrawn_at", where: "(withdrawn_at IS NOT NULL)"
    t.check_constraint "user_identity_status_id IS NULL OR user_identity_status_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_users_user_identity_status_id_format"
  end

  create_table "workspaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "zip_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_zip_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_zip_occurrence_statuses_id_format"
  end

  create_table "zip_occurrences", force: :cascade do |t|
    t.string "body", limit: 16, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_zip_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_zip_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_zip_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_zip_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_zip_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_zip_occurrences_public_id_format"
  end

  add_foreign_key "app_contact_emails", "app_contacts"
  add_foreign_key "app_contact_telephones", "app_contacts"
  add_foreign_key "app_contact_topics", "app_contacts"
  add_foreign_key "app_contacts", "app_contact_categories", column: "contact_category_title"
  add_foreign_key "app_contacts", "app_contact_statuses", column: "contact_status_id"
  add_foreign_key "apple_auths", "users"
  add_foreign_key "area_domain_occurrences", "area_occurrences"
  add_foreign_key "area_domain_occurrences", "domain_occurrences"
  add_foreign_key "area_email_occurrences", "area_occurrences"
  add_foreign_key "area_email_occurrences", "email_occurrences"
  add_foreign_key "area_ip_occurrences", "area_occurrences"
  add_foreign_key "area_ip_occurrences", "ip_occurrences"
  add_foreign_key "area_staff_occurrences", "area_occurrences"
  add_foreign_key "area_staff_occurrences", "staff_occurrences"
  add_foreign_key "area_telephone_occurrences", "area_occurrences"
  add_foreign_key "area_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "area_user_occurrences", "area_occurrences"
  add_foreign_key "area_user_occurrences", "user_occurrences"
  add_foreign_key "area_zip_occurrences", "area_occurrences"
  add_foreign_key "area_zip_occurrences", "zip_occurrences"
  add_foreign_key "com_contact_audits", "com_contacts"
  add_foreign_key "com_contact_topics", "com_contacts"
  add_foreign_key "com_contacts", "com_contact_categories", column: "contact_category_title"
  add_foreign_key "com_contacts", "com_contact_statuses", column: "contact_status_id"
  add_foreign_key "domain_email_occurrences", "domain_occurrences"
  add_foreign_key "domain_email_occurrences", "email_occurrences"
  add_foreign_key "domain_ip_occurrences", "domain_occurrences"
  add_foreign_key "domain_ip_occurrences", "ip_occurrences"
  add_foreign_key "domain_staff_occurrences", "domain_occurrences"
  add_foreign_key "domain_staff_occurrences", "staff_occurrences"
  add_foreign_key "domain_telephone_occurrences", "domain_occurrences"
  add_foreign_key "domain_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "domain_user_occurrences", "domain_occurrences"
  add_foreign_key "domain_user_occurrences", "user_occurrences"
  add_foreign_key "domain_zip_occurrences", "domain_occurrences"
  add_foreign_key "domain_zip_occurrences", "zip_occurrences"
  add_foreign_key "email_ip_occurrences", "email_occurrences"
  add_foreign_key "email_ip_occurrences", "ip_occurrences"
  add_foreign_key "email_staff_occurrences", "email_occurrences"
  add_foreign_key "email_staff_occurrences", "staff_occurrences"
  add_foreign_key "email_telephone_occurrences", "email_occurrences"
  add_foreign_key "email_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "email_user_occurrences", "email_occurrences"
  add_foreign_key "email_user_occurrences", "user_occurrences"
  add_foreign_key "email_zip_occurrences", "email_occurrences"
  add_foreign_key "email_zip_occurrences", "zip_occurrences"
  add_foreign_key "google_auths", "users"
  add_foreign_key "ip_staff_occurrences", "ip_occurrences"
  add_foreign_key "ip_staff_occurrences", "staff_occurrences"
  add_foreign_key "ip_telephone_occurrences", "ip_occurrences"
  add_foreign_key "ip_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "ip_user_occurrences", "ip_occurrences"
  add_foreign_key "ip_user_occurrences", "user_occurrences"
  add_foreign_key "ip_zip_occurrences", "ip_occurrences"
  add_foreign_key "ip_zip_occurrences", "zip_occurrences"
  add_foreign_key "org_contact_emails", "org_contacts"
  add_foreign_key "org_contact_telephones", "org_contacts"
  add_foreign_key "org_contact_topics", "org_contacts"
  add_foreign_key "org_contacts", "org_contact_categories", column: "contact_category_title"
  add_foreign_key "org_contacts", "org_contact_statuses", column: "contact_status_id"
  add_foreign_key "role_assignments", "staffs", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "staff_identity_emails", "staff_identity_email_statuses"
  add_foreign_key "staff_identity_emails", "staffs"
  add_foreign_key "staff_identity_passkeys", "staffs"
  add_foreign_key "staff_identity_secrets", "staff_identity_secret_statuses"
  add_foreign_key "staff_identity_secrets", "staffs"
  add_foreign_key "staff_identity_telephones", "staff_identity_telephone_statuses"
  add_foreign_key "staff_identity_telephones", "staffs"
  add_foreign_key "staff_passkeys", "staffs"
  add_foreign_key "staff_recovery_codes", "staffs"
  add_foreign_key "staff_telephone_occurrences", "staff_occurrences"
  add_foreign_key "staff_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "staff_tokens", "staff_token_statuses"
  add_foreign_key "staff_user_occurrences", "staff_occurrences"
  add_foreign_key "staff_user_occurrences", "user_occurrences"
  add_foreign_key "staff_zip_occurrences", "staff_occurrences"
  add_foreign_key "staff_zip_occurrences", "zip_occurrences"
  add_foreign_key "staffs", "staff_identity_statuses"
  add_foreign_key "telephone_user_occurrences", "telephone_occurrences"
  add_foreign_key "telephone_user_occurrences", "user_occurrences"
  add_foreign_key "telephone_zip_occurrences", "telephone_occurrences"
  add_foreign_key "telephone_zip_occurrences", "zip_occurrences"
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
  add_foreign_key "user_passkeys", "users"
  add_foreign_key "user_tokens", "user_token_statuses"
  add_foreign_key "user_workspaces", "workspaces"
  add_foreign_key "user_zip_occurrences", "user_occurrences"
  add_foreign_key "user_zip_occurrences", "zip_occurrences"
  add_foreign_key "users", "user_identity_statuses"
end
