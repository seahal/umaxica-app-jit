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

ActiveRecord::Schema[8.2].define(version: 2026_01_16_122000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_contact_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_contact_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_contact_histories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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

  create_table "app_document_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "app_document_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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
    t.index ["subject_id"], name: "index_app_document_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_cf1fa79ee4"
  end

  create_table "app_preference_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "app_preference_audit_events_id_format_check"
  end

  create_table "app_preference_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "app_preference_audit_levels_id_format_check"
  end

  create_table "app_preference_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_preference_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_preference_audits_on_event_id"
    t.index ["expires_at"], name: "index_app_preference_audits_on_expires_at"
    t.index ["level_id"], name: "index_app_preference_audits_on_level_id"
    t.index ["occurred_at"], name: "index_app_preference_audits_on_occurred_at"
    t.index ["subject_id"], name: "index_app_preference_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_app_pref"
  end

  create_table "app_timeline_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "app_timeline_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "app_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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
    t.index ["subject_id"], name: "index_app_timeline_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_c80b4e4f83"
  end

  create_table "com_contact_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_contact_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_contact_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "", null: false
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

  create_table "com_document_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "com_document_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "com_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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
    t.index ["subject_id"], name: "index_com_document_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_c40361e81b"
  end

  create_table "com_preference_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "com_preference_audit_events_id_format_check"
  end

  create_table "com_preference_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "com_preference_audit_levels_id_format_check"
  end

  create_table "com_preference_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_preference_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_preference_audits_on_event_id"
    t.index ["expires_at"], name: "index_com_preference_audits_on_expires_at"
    t.index ["level_id"], name: "index_com_preference_audits_on_level_id"
    t.index ["occurred_at"], name: "index_com_preference_audits_on_occurred_at"
    t.index ["subject_id"], name: "index_com_preference_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_com_pref"
  end

  create_table "com_timeline_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "com_timeline_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "com_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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
    t.index ["subject_id"], name: "index_com_timeline_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_99ec847a5c"
  end

  create_table "org_contact_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_contact_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_contact_histories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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

  create_table "org_document_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "org_document_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "org_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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
    t.index ["subject_id"], name: "index_org_document_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_bf53171ad0"
  end

  create_table "org_preference_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "org_preference_audit_events_id_format_check"
  end

  create_table "org_preference_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "org_preference_audit_levels_id_format_check"
  end

  create_table "org_preference_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_preference_audits_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_preference_audits_on_event_id"
    t.index ["expires_at"], name: "index_org_preference_audits_on_expires_at"
    t.index ["level_id"], name: "index_org_preference_audits_on_level_id"
    t.index ["occurred_at"], name: "index_org_preference_audits_on_occurred_at"
    t.index ["subject_id"], name: "index_org_preference_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_org_pref"
  end

  create_table "org_timeline_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "org_timeline_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
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
    t.index ["subject_id"], name: "index_org_timeline_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_0f4341deba"
  end

  create_table "staff_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "staff_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
  end

  create_table "staff_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_staff_identity_audits_on_actor_id_and_occurred_at"
    t.index ["actor_type", "actor_id"], name: "index_staff_identity_audits_on_actor"
    t.index ["event_id"], name: "index_staff_identity_audits_on_event_id"
    t.index ["expires_at"], name: "index_staff_identity_audits_on_expires_at"
    t.index ["level_id"], name: "index_staff_identity_audits_on_level_id"
    t.index ["occurred_at"], name: "index_staff_identity_audits_on_occurred_at"
    t.index ["subject_id"], name: "index_staff_identity_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_2e96c29236"
  end

  create_table "user_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "NEYO", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.string "level_id", limit: 255, default: "NEYO", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.string "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_user_identity_audits_on_actor_id_and_occurred_at"
    t.index ["actor_type", "actor_id"], name: "index_user_identity_audits_on_actor"
    t.index ["event_id"], name: "index_user_identity_audits_on_event_id"
    t.index ["expires_at"], name: "index_user_identity_audits_on_expires_at"
    t.index ["level_id"], name: "index_user_identity_audits_on_level_id"
    t.index ["occurred_at"], name: "index_user_identity_audits_on_occurred_at"
    t.index ["subject_id"], name: "index_user_identity_audits_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_a29eb711dd"
  end

  add_foreign_key "app_contact_histories", "app_contact_audit_events", column: "event_id"
  add_foreign_key "app_contact_histories", "app_contact_audit_levels", column: "level_id"
  add_foreign_key "app_document_audits", "app_document_audit_events", column: "event_id"
  add_foreign_key "app_document_audits", "app_document_audit_levels", column: "level_id"
  add_foreign_key "app_timeline_audits", "app_timeline_audit_events", column: "event_id"
  add_foreign_key "app_timeline_audits", "app_timeline_audit_levels", column: "level_id"
  add_foreign_key "com_contact_audits", "com_contact_audit_events", column: "event_id"
  add_foreign_key "com_contact_audits", "com_contact_audit_levels", column: "level_id"
  add_foreign_key "com_document_audits", "com_document_audit_events", column: "event_id"
  add_foreign_key "com_document_audits", "com_document_audit_levels", column: "level_id"
  add_foreign_key "com_timeline_audits", "com_timeline_audit_events", column: "event_id"
  add_foreign_key "com_timeline_audits", "com_timeline_audit_levels", column: "level_id"
  add_foreign_key "org_contact_histories", "org_contact_audit_events", column: "event_id"
  add_foreign_key "org_contact_histories", "org_contact_audit_levels", column: "level_id"
  add_foreign_key "org_document_audits", "org_document_audit_events", column: "event_id"
  add_foreign_key "org_document_audits", "org_document_audit_levels", column: "level_id"
  add_foreign_key "org_timeline_audits", "org_timeline_audit_events", column: "event_id"
  add_foreign_key "org_timeline_audits", "org_timeline_audit_levels", column: "level_id"
  add_foreign_key "staff_audits", "staff_audit_events", column: "event_id"
  add_foreign_key "staff_audits", "staff_audit_levels", column: "level_id"
  add_foreign_key "user_audits", "user_audit_events", column: "event_id"
  add_foreign_key "user_audits", "user_audit_levels", column: "level_id"
end
