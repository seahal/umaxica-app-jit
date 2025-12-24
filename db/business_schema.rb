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

ActiveRecord::Schema[8.2].define(version: 2025_12_24_173000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.uuid "app_document_audit_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.index ["app_document_audit_id"], name: "index_app_document_audit_events_on_app_document_audit_id"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_document_audit_events_id_format"
  end

  create_table "app_document_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_document_audit_levels_id_format"
  end

  create_table "app_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.uuid "app_document_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.text "previous_value", default: "", null: false
    t.datetime "timestamp", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_document_audits_on_actor_type_and_actor_id"
    t.index ["app_document_id"], name: "index_app_document_audits_on_app_document_id"
    t.index ["level_id"], name: "index_app_document_audits_on_level_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_document_audits_event_id_format"
    t.check_constraint "level_id IS NULL OR level_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_document_audits_level_id_format"
  end

  create_table "app_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_document_statuses_id_format"
  end

  create_table "app_documents", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "app_document_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "prev_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "succ_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["app_document_status_id"], name: "index_app_documents_on_app_document_status_id"
    t.index ["parent_id"], name: "index_app_documents_on_parent_id"
    t.index ["prev_id"], name: "index_app_documents_on_prev_id"
    t.index ["public_id"], name: "index_app_documents_on_public_id"
    t.index ["staff_id"], name: "index_app_documents_on_staff_id"
    t.index ["succ_id"], name: "index_app_documents_on_succ_id"
  end

  create_table "app_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_audit_events_id_format"
  end

  create_table "app_timeline_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_audit_levels_id_format"
  end

  create_table "app_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.uuid "app_timeline_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.text "previous_value", default: "", null: false
    t.datetime "timestamp", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_timeline_audits_on_actor_type_and_actor_id"
    t.index ["app_timeline_id"], name: "index_app_timeline_audits_on_app_timeline_id"
    t.index ["level_id"], name: "index_app_timeline_audits_on_level_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_audits_event_id_format"
    t.check_constraint "level_id IS NULL OR level_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_audits_level_id_format"
  end

  create_table "app_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_statuses_id_format"
  end

  create_table "app_timelines", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "app_timeline_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "prev_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "succ_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["app_timeline_status_id"], name: "index_app_timelines_on_app_timeline_status_id"
    t.index ["parent_id"], name: "index_app_timelines_on_parent_id"
    t.index ["prev_id"], name: "index_app_timelines_on_prev_id"
    t.index ["public_id"], name: "index_app_timelines_on_public_id"
    t.index ["staff_id"], name: "index_app_timelines_on_staff_id"
    t.index ["succ_id"], name: "index_app_timelines_on_succ_id"
  end

  create_table "com_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_document_audit_events_id_format"
  end

  create_table "com_document_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_document_audit_levels_id_format"
  end

  create_table "com_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.uuid "com_document_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.text "previous_value", default: "", null: false
    t.datetime "timestamp", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_document_audits_on_actor_type_and_actor_id"
    t.index ["com_document_id"], name: "index_com_document_audits_on_com_document_id"
    t.index ["level_id"], name: "index_com_document_audits_on_level_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_document_audits_event_id_format"
    t.check_constraint "level_id IS NULL OR level_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_document_audits_level_id_format"
  end

  create_table "com_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_document_statuses_id_format"
  end

  create_table "com_documents", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "com_document_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "prev_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "succ_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["com_document_status_id"], name: "index_com_documents_on_com_document_status_id"
    t.index ["parent_id"], name: "index_com_documents_on_parent_id"
    t.index ["prev_id"], name: "index_com_documents_on_prev_id"
    t.index ["public_id"], name: "index_com_documents_on_public_id"
    t.index ["staff_id"], name: "index_com_documents_on_staff_id"
    t.index ["succ_id"], name: "index_com_documents_on_succ_id"
  end

  create_table "com_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_audit_events_id_format"
  end

  create_table "com_timeline_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_audit_levels_id_format"
  end

  create_table "com_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.uuid "com_timeline_id", null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.text "previous_value", default: "", null: false
    t.datetime "timestamp", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_timeline_audits_on_actor_type_and_actor_id"
    t.index ["com_timeline_id"], name: "index_com_timeline_audits_on_com_timeline_id"
    t.index ["level_id"], name: "index_com_timeline_audits_on_level_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_audits_event_id_format"
    t.check_constraint "level_id IS NULL OR level_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_audits_level_id_format"
  end

  create_table "com_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_statuses_id_format"
  end

  create_table "com_timelines", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "com_timeline_status_id", limit: 255, default: "NONE", null: false
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "prev_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "succ_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["com_timeline_status_id"], name: "index_com_timelines_on_com_timeline_status_id"
    t.index ["parent_id"], name: "index_com_timelines_on_parent_id"
    t.index ["prev_id"], name: "index_com_timelines_on_prev_id"
    t.index ["public_id"], name: "index_com_timelines_on_public_id"
    t.index ["staff_id"], name: "index_com_timelines_on_staff_id"
    t.index ["succ_id"], name: "index_com_timelines_on_succ_id"
  end

  create_table "entity_statuses", id: :string, force: :cascade do |t|
  end

  create_table "org_document_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_document_audit_events_id_format"
  end

  create_table "org_document_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_document_audit_levels_id_format"
  end

  create_table "org_document_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.uuid "org_document_id", null: false
    t.text "previous_value", default: "", null: false
    t.datetime "timestamp", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_document_audits_on_actor_type_and_actor_id"
    t.index ["level_id"], name: "index_org_document_audits_on_level_id"
    t.index ["org_document_id"], name: "index_org_document_audits_on_org_document_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_document_audits_event_id_format"
    t.check_constraint "level_id IS NULL OR level_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_document_audits_level_id_format"
  end

  create_table "org_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_document_statuses_id_format"
  end

  create_table "org_documents", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.string "org_document_status_id", limit: 255, default: "NONE", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "prev_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "succ_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["org_document_status_id"], name: "index_org_documents_on_org_document_status_id"
    t.index ["parent_id"], name: "index_org_documents_on_parent_id"
    t.index ["prev_id"], name: "index_org_documents_on_prev_id"
    t.index ["public_id"], name: "index_org_documents_on_public_id"
    t.index ["staff_id"], name: "index_org_documents_on_staff_id"
    t.index ["succ_id"], name: "index_org_documents_on_succ_id"
  end

  create_table "org_timeline_audit_events", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_audit_events_id_format"
  end

  create_table "org_timeline_audit_levels", id: :string, default: "NONE", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_audit_levels_id_format"
  end

  create_table "org_timeline_audits", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "actor_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "actor_type", default: "", null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.string "event_id", limit: 255, default: "", null: false
    t.string "ip_address", default: "", null: false
    t.string "level_id", default: "NONE", null: false
    t.uuid "org_timeline_id", null: false
    t.text "previous_value", default: "", null: false
    t.datetime "timestamp", default: -::Float::INFINITY, null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_timeline_audits_on_actor_type_and_actor_id"
    t.index ["level_id"], name: "index_org_timeline_audits_on_level_id"
    t.index ["org_timeline_id"], name: "index_org_timeline_audits_on_org_timeline_id"
    t.check_constraint "event_id IS NULL OR event_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_audits_event_id_format"
    t.check_constraint "level_id IS NULL OR level_id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_audits_level_id_format"
  end

  create_table "org_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_statuses_id_format"
  end

  create_table "org_timelines", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: "", null: false
    t.string "org_timeline_status_id", limit: 255, default: "NONE", null: false
    t.uuid "parent_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "prev_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "succ_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.string "title", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["org_timeline_status_id"], name: "index_org_timelines_on_org_timeline_status_id"
    t.index ["parent_id"], name: "index_org_timelines_on_parent_id"
    t.index ["prev_id"], name: "index_org_timelines_on_prev_id"
    t.index ["public_id"], name: "index_org_timelines_on_public_id"
    t.index ["staff_id"], name: "index_org_timelines_on_staff_id"
    t.index ["succ_id"], name: "index_org_timelines_on_succ_id"
  end

  add_foreign_key "app_document_audits", "app_document_audit_events", column: "event_id"
  add_foreign_key "app_document_audits", "app_document_audit_levels", column: "level_id"
  add_foreign_key "app_document_audits", "app_documents"
  add_foreign_key "app_timeline_audits", "app_timeline_audit_events", column: "event_id"
  add_foreign_key "app_timeline_audits", "app_timeline_audit_levels", column: "level_id"
  add_foreign_key "app_timeline_audits", "app_timelines"
  add_foreign_key "com_document_audits", "com_document_audit_events", column: "event_id"
  add_foreign_key "com_document_audits", "com_document_audit_levels", column: "level_id"
  add_foreign_key "com_document_audits", "com_documents"
  add_foreign_key "com_timeline_audits", "com_timeline_audit_events", column: "event_id"
  add_foreign_key "com_timeline_audits", "com_timeline_audit_levels", column: "level_id"
  add_foreign_key "com_timeline_audits", "com_timelines"
  add_foreign_key "org_document_audits", "org_document_audit_events", column: "event_id"
  add_foreign_key "org_document_audits", "org_document_audit_levels", column: "level_id"
  add_foreign_key "org_document_audits", "org_documents"
  add_foreign_key "org_timeline_audits", "org_timeline_audit_events", column: "event_id"
  add_foreign_key "org_timeline_audits", "org_timeline_audit_levels", column: "level_id"
  add_foreign_key "org_timeline_audits", "org_timelines"
end
