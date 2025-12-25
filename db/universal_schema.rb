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

ActiveRecord::Schema[8.2].define(version: 2025_12_25_224130) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "app_contact_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_contact_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_contact_histories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_contact_histories_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_contact_histories_on_event_id"
    t.index ["expires_at"], name: "index_app_contact_histories_on_expires_at"
    t.index ["level_id"], name: "index_app_contact_histories_on_level_id"
    t.index ["occurred_at"], name: "index_app_contact_histories_on_occurred_at"
    t.index ["parent_id"], name: "index_app_contact_histories_on_parent_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_21d52ab3f6"
  end

  create_table "app_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_document_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_document_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_document_audits_on_event_id"
    t.index ["expires_at"], name: "index_app_document_audits_on_expires_at"
    t.index ["level_id"], name: "index_app_document_audits_on_level_id"
    t.index ["occurred_at"], name: "index_app_document_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_cf1fa79ee4"
  end

  create_table "app_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_timeline_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_timeline_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_timeline_audits_on_event_id"
    t.index ["expires_at"], name: "index_app_timeline_audits_on_expires_at"
    t.index ["level_id"], name: "index_app_timeline_audits_on_level_id"
    t.index ["occurred_at"], name: "index_app_timeline_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_c80b4e4f83"
  end

  create_table "area_domain_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_domain_occurrences_on_area_occurrence_id"
    t.index ["domain_occurrence_id"], name: "index_area_domain_occurrences_on_domain_occurrence_id"
  end

  create_table "area_email_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.uuid "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_email_occurrences_on_area_occurrence_id"
    t.index ["email_occurrence_id"], name: "index_area_email_occurrences_on_email_occurrence_id"
  end

  create_table "area_ip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.uuid "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_ip_occurrences_on_area_occurrence_id"
    t.index ["ip_occurrence_id"], name: "index_area_ip_occurrences_on_ip_occurrence_id"
  end

  create_table "area_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_area_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_area_occurrence_statuses_id_format"
  end

  create_table "area_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "area_staff_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.uuid "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_staff_occurrences_on_area_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_area_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "area_telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["area_occurrence_id"], name: "index_area_telephone_occurrences_on_area_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_area_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "area_user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.index ["area_occurrence_id"], name: "index_area_user_occurrences_on_area_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_area_user_occurrences_on_user_occurrence_id"
  end

  create_table "area_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "area_occurrence_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["area_occurrence_id"], name: "index_area_zip_occurrences_on_area_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_area_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "com_contact_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_contact_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_contact_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_contact_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_contact_audits_on_event_id"
    t.index ["expires_at"], name: "index_com_contact_audits_on_expires_at"
    t.index ["level_id"], name: "index_com_contact_audits_on_level_id"
    t.index ["occurred_at"], name: "index_com_contact_audits_on_occurred_at"
    t.index ["parent_id"], name: "index_com_contact_audits_on_parent_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_1ec6aec32c"
  end

  create_table "com_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_document_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_document_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_document_audits_on_event_id"
    t.index ["expires_at"], name: "index_com_document_audits_on_expires_at"
    t.index ["level_id"], name: "index_com_document_audits_on_level_id"
    t.index ["occurred_at"], name: "index_com_document_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_c40361e81b"
  end

  create_table "com_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_timeline_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_timeline_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_timeline_audits_on_event_id"
    t.index ["expires_at"], name: "index_com_timeline_audits_on_expires_at"
    t.index ["level_id"], name: "index_com_timeline_audits_on_level_id"
    t.index ["occurred_at"], name: "index_com_timeline_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_99ec847a5c"
  end

  create_table "domain_email_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.uuid "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_email_occurrences_on_domain_occurrence_id"
    t.index ["email_occurrence_id"], name: "index_domain_email_occurrences_on_email_occurrence_id"
  end

  create_table "domain_ip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.uuid "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_ip_occurrences_on_domain_occurrence_id"
    t.index ["ip_occurrence_id"], name: "index_domain_ip_occurrences_on_ip_occurrence_id"
  end

  create_table "domain_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_domain_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_domain_occurrence_statuses_id_format"
  end

  create_table "domain_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "domain_staff_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.uuid "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_staff_occurrences_on_domain_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_domain_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "domain_telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_telephone_occurrences_on_domain_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_domain_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "domain_user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_user_occurrences_on_domain_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_domain_user_occurrences_on_user_occurrence_id"
  end

  create_table "domain_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "domain_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["domain_occurrence_id"], name: "index_domain_zip_occurrences_on_domain_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_domain_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "email_ip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_occurrence_id", null: false
    t.uuid "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_occurrence_id"], name: "index_email_ip_occurrences_on_email_occurrence_id"
    t.index ["ip_occurrence_id"], name: "index_email_ip_occurrences_on_ip_occurrence_id"
  end

  create_table "email_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_email_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_email_occurrence_statuses_id_format"
  end

  create_table "email_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "email_staff_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_occurrence_id", null: false
    t.uuid "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_occurrence_id"], name: "index_email_staff_occurrences_on_email_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_email_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "email_telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_occurrence_id", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email_occurrence_id"], name: "index_email_telephone_occurrences_on_email_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_email_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "email_user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.index ["email_occurrence_id"], name: "index_email_user_occurrences_on_email_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_email_user_occurrences_on_user_occurrence_id"
  end

  create_table "email_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["email_occurrence_id"], name: "index_email_zip_occurrences_on_email_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_email_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "ip_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_ip_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_ip_occurrence_statuses_id_format"
  end

  create_table "ip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "ip_staff_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "ip_occurrence_id", null: false
    t.uuid "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_staff_occurrences_on_ip_occurrence_id"
    t.index ["staff_occurrence_id"], name: "index_ip_staff_occurrences_on_staff_occurrence_id"
  end

  create_table "ip_telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "ip_occurrence_id", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_telephone_occurrences_on_ip_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_ip_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "ip_user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_user_occurrences_on_ip_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_ip_user_occurrences_on_user_occurrence_id"
  end

  create_table "ip_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "ip_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["ip_occurrence_id"], name: "index_ip_zip_occurrences_on_ip_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_ip_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "org_contact_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_contact_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_contact_histories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.integer "position", default: 0, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_contact_histories_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_contact_histories_on_event_id"
    t.index ["expires_at"], name: "index_org_contact_histories_on_expires_at"
    t.index ["level_id"], name: "index_org_contact_histories_on_level_id"
    t.index ["occurred_at"], name: "index_org_contact_histories_on_occurred_at"
    t.index ["parent_id"], name: "index_org_contact_histories_on_parent_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_3eb778d373"
  end

  create_table "org_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_document_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_document_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_document_audits_on_event_id"
    t.index ["expires_at"], name: "index_org_document_audits_on_expires_at"
    t.index ["level_id"], name: "index_org_document_audits_on_level_id"
    t.index ["occurred_at"], name: "index_org_document_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_bf53171ad0"
  end

  create_table "org_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_timeline_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_timeline_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_timeline_audits_on_event_id"
    t.index ["expires_at"], name: "index_org_timeline_audits_on_expires_at"
    t.index ["level_id"], name: "index_org_timeline_audits_on_level_id"
    t.index ["occurred_at"], name: "index_org_timeline_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_0f4341deba"
  end

  create_table "staff_identity_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_identity_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_staff_identity_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_staff_identity_audits_on_event_id"
    t.index ["expires_at"], name: "index_staff_identity_audits_on_expires_at"
    t.index ["level_id"], name: "index_staff_identity_audits_on_level_id"
    t.index ["occurred_at"], name: "index_staff_identity_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_2e96c29236"
  end

  create_table "staff_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_staff_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_occurrence_statuses_id_format"
  end

  create_table "staff_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "staff_telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "staff_occurrence_id", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_occurrence_id"], name: "index_staff_telephone_occurrences_on_staff_occurrence_id"
    t.index ["telephone_occurrence_id"], name: "index_staff_telephone_occurrences_on_telephone_occurrence_id"
  end

  create_table "staff_user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.index ["staff_occurrence_id"], name: "index_staff_user_occurrences_on_staff_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_staff_user_occurrences_on_user_occurrence_id"
  end

  create_table "staff_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "staff_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["staff_occurrence_id"], name: "index_staff_zip_occurrences_on_staff_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_staff_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "telephone_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_telephone_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_telephone_occurrence_statuses_id_format"
  end

  create_table "telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "telephone_user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.index ["telephone_occurrence_id"], name: "index_telephone_user_occurrences_on_telephone_occurrence_id"
    t.index ["user_occurrence_id"], name: "index_telephone_user_occurrences_on_user_occurrence_id"
  end

  create_table "telephone_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "telephone_occurrence_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["telephone_occurrence_id"], name: "index_telephone_zip_occurrences_on_telephone_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_telephone_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "user_identity_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audit_levels", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_identity_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NONE", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NONE", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_user_identity_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_user_identity_audits_on_event_id"
    t.index ["expires_at"], name: "index_user_identity_audits_on_expires_at"
    t.index ["level_id"], name: "index_user_identity_audits_on_level_id"
    t.index ["occurred_at"], name: "index_user_identity_audits_on_occurred_at"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_a29eb711dd"
  end

  create_table "user_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_user_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_occurrence_statuses_id_format"
  end

  create_table "user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  create_table "user_zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_occurrence_id", null: false
    t.uuid "zip_occurrence_id", null: false
    t.index ["user_occurrence_id"], name: "index_user_zip_occurrences_on_user_occurrence_id"
    t.index ["zip_occurrence_id"], name: "index_user_zip_occurrences_on_zip_occurrence_id"
  end

  create_table "zip_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_zip_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_zip_occurrence_statuses_id_format"
  end

  create_table "zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
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

  add_foreign_key "app_contact_histories", "app_contact_audit_events", column: "event_id"
  add_foreign_key "app_contact_histories", "app_contact_audit_levels", column: "level_id"
  add_foreign_key "app_document_audits", "app_document_audit_events", column: "event_id"
  add_foreign_key "app_document_audits", "app_document_audit_levels", column: "level_id"
  add_foreign_key "app_timeline_audits", "app_timeline_audit_events", column: "event_id"
  add_foreign_key "app_timeline_audits", "app_timeline_audit_levels", column: "level_id"
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
  add_foreign_key "com_contact_audits", "com_contact_audit_events", column: "event_id"
  add_foreign_key "com_contact_audits", "com_contact_audit_levels", column: "level_id"
  add_foreign_key "com_document_audits", "com_document_audit_events", column: "event_id"
  add_foreign_key "com_document_audits", "com_document_audit_levels", column: "level_id"
  add_foreign_key "com_timeline_audits", "com_timeline_audit_events", column: "event_id"
  add_foreign_key "com_timeline_audits", "com_timeline_audit_levels", column: "level_id"
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
  add_foreign_key "ip_staff_occurrences", "ip_occurrences"
  add_foreign_key "ip_staff_occurrences", "staff_occurrences"
  add_foreign_key "ip_telephone_occurrences", "ip_occurrences"
  add_foreign_key "ip_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "ip_user_occurrences", "ip_occurrences"
  add_foreign_key "ip_user_occurrences", "user_occurrences"
  add_foreign_key "ip_zip_occurrences", "ip_occurrences"
  add_foreign_key "ip_zip_occurrences", "zip_occurrences"
  add_foreign_key "org_contact_histories", "org_contact_audit_events", column: "event_id"
  add_foreign_key "org_contact_histories", "org_contact_audit_levels", column: "level_id"
  add_foreign_key "org_document_audits", "org_document_audit_events", column: "event_id"
  add_foreign_key "org_document_audits", "org_document_audit_levels", column: "level_id"
  add_foreign_key "org_timeline_audits", "org_timeline_audit_events", column: "event_id"
  add_foreign_key "org_timeline_audits", "org_timeline_audit_levels", column: "level_id"
  add_foreign_key "staff_identity_audits", "staff_identity_audit_events", column: "event_id"
  add_foreign_key "staff_identity_audits", "staff_identity_audit_levels", column: "level_id"
  add_foreign_key "staff_telephone_occurrences", "staff_occurrences"
  add_foreign_key "staff_telephone_occurrences", "telephone_occurrences"
  add_foreign_key "staff_user_occurrences", "staff_occurrences"
  add_foreign_key "staff_user_occurrences", "user_occurrences"
  add_foreign_key "staff_zip_occurrences", "staff_occurrences"
  add_foreign_key "staff_zip_occurrences", "zip_occurrences"
  add_foreign_key "telephone_user_occurrences", "telephone_occurrences"
  add_foreign_key "telephone_user_occurrences", "user_occurrences"
  add_foreign_key "telephone_zip_occurrences", "telephone_occurrences"
  add_foreign_key "telephone_zip_occurrences", "zip_occurrences"
  add_foreign_key "user_identity_audits", "user_identity_audit_events", column: "event_id"
  add_foreign_key "user_identity_audits", "user_identity_audit_levels", column: "level_id"
  add_foreign_key "user_zip_occurrences", "user_occurrences"
  add_foreign_key "user_zip_occurrences", "zip_occurrences"
end
