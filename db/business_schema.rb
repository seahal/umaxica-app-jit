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

ActiveRecord::Schema[8.2].define(version: 2025_12_26_000012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "app_document_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.uuid "app_document_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["app_document_id"], name: "index_app_document_audits_on_app_document_id"
    t.index ["event_id"], name: "index_app_document_audits_on_event_id"
    t.index ["subject_id"], name: "index_app_document_audits_on_subject_id"
  end

  create_table "app_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_document_statuses_id_format"
  end

  create_table "app_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "app_timeline_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.uuid "app_timeline_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["app_timeline_id"], name: "index_app_timeline_audits_on_app_timeline_id"
    t.index ["event_id"], name: "index_app_timeline_audits_on_event_id"
    t.index ["subject_id"], name: "index_app_timeline_audits_on_subject_id"
  end

  create_table "app_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_statuses_id_format"
  end

  create_table "com_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "com_document_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.uuid "com_document_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["com_document_id"], name: "index_com_document_audits_on_com_document_id"
    t.index ["event_id"], name: "index_com_document_audits_on_event_id"
    t.index ["subject_id"], name: "index_com_document_audits_on_subject_id"
  end

  create_table "com_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_document_statuses_id_format"
  end

  create_table "com_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "com_timeline_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.uuid "com_timeline_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["com_timeline_id"], name: "index_com_timeline_audits_on_com_timeline_id"
    t.index ["event_id"], name: "index_com_timeline_audits_on_event_id"
    t.index ["subject_id"], name: "index_com_timeline_audits_on_subject_id"
  end

  create_table "com_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_statuses_id_format"
  end

  create_table "entity_statuses", id: :string, force: :cascade do |t|
  end

  create_table "org_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "org_document_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.uuid "org_document_id", null: false
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_org_document_audits_on_event_id"
    t.index ["org_document_id"], name: "index_org_document_audits_on_org_document_id"
    t.index ["subject_id"], name: "index_org_document_audits_on_subject_id"
  end

  create_table "org_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_document_statuses_id_format"
  end

  create_table "org_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
  end

  create_table "org_timeline_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.text "current_value"
    t.string "event_id", limit: 255, null: false
    t.string "ip_address"
    t.uuid "org_timeline_id", null: false
    t.text "previous_value"
    t.string "subject_id"
    t.string "subject_type", default: "", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_org_timeline_audits_on_event_id"
    t.index ["org_timeline_id"], name: "index_org_timeline_audits_on_org_timeline_id"
    t.index ["subject_id"], name: "index_org_timeline_audits_on_subject_id"
  end

  create_table "org_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_statuses_id_format"
  end
end
