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

ActiveRecord::Schema[8.2].define(version: 2026_02_26_170002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_contact_behavior_events", force: :cascade do |t|
  end

  create_table "app_contact_behavior_levels", force: :cascade do |t|
  end

  create_table "app_contact_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_contact_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_app_contact_behaviors_on_event_id"
    t.index ["level_id"], name: "index_app_contact_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_app_contact_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_app_contact_behaviors_on_subject_type_and_subject_id"
  end

  create_table "app_document_behavior_events", force: :cascade do |t|
  end

  create_table "app_document_behavior_levels", force: :cascade do |t|
  end

  create_table "app_document_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_document_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_app_document_behaviors_on_event_id"
    t.index ["level_id"], name: "index_app_document_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_app_document_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_app_document_behaviors_on_subject_type_and_subject_id"
  end

  create_table "app_timeline_behavior_events", force: :cascade do |t|
  end

  create_table "app_timeline_behavior_levels", force: :cascade do |t|
  end

  create_table "app_timeline_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_timeline_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_app_timeline_behaviors_on_event_id"
    t.index ["level_id"], name: "index_app_timeline_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_app_timeline_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_app_timeline_behaviors_on_subject_type_and_subject_id"
  end

  create_table "com_contact_behavior_events", force: :cascade do |t|
  end

  create_table "com_contact_behavior_levels", force: :cascade do |t|
  end

  create_table "com_contact_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_contact_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_com_contact_behaviors_on_event_id"
    t.index ["level_id"], name: "index_com_contact_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_com_contact_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_com_contact_behaviors_on_subject_type_and_subject_id"
  end

  create_table "com_document_behavior_events", force: :cascade do |t|
  end

  create_table "com_document_behavior_levels", force: :cascade do |t|
  end

  create_table "com_document_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_document_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_com_document_behaviors_on_event_id"
    t.index ["level_id"], name: "index_com_document_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_com_document_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_com_document_behaviors_on_subject_type_and_subject_id"
  end

  create_table "com_timeline_behavior_events", force: :cascade do |t|
  end

  create_table "com_timeline_behavior_levels", force: :cascade do |t|
  end

  create_table "com_timeline_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_timeline_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_com_timeline_behaviors_on_event_id"
    t.index ["level_id"], name: "index_com_timeline_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_com_timeline_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_com_timeline_behaviors_on_subject_type_and_subject_id"
  end

  create_table "org_contact_behavior_events", force: :cascade do |t|
  end

  create_table "org_contact_behavior_levels", force: :cascade do |t|
  end

  create_table "org_contact_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_contact_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_org_contact_behaviors_on_event_id"
    t.index ["level_id"], name: "index_org_contact_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_org_contact_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_org_contact_behaviors_on_subject_type_and_subject_id"
  end

  create_table "org_document_behavior_events", force: :cascade do |t|
  end

  create_table "org_document_behavior_levels", force: :cascade do |t|
  end

  create_table "org_document_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_document_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_org_document_behaviors_on_event_id"
    t.index ["level_id"], name: "index_org_document_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_org_document_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_org_document_behaviors_on_subject_type_and_subject_id"
  end

  create_table "org_timeline_behavior_events", force: :cascade do |t|
  end

  create_table "org_timeline_behavior_levels", force: :cascade do |t|
  end

  create_table "org_timeline_behaviors", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "expires_at"
    t.bigint "level_id", null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_timeline_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_org_timeline_behaviors_on_event_id"
    t.index ["level_id"], name: "index_org_timeline_behaviors_on_level_id"
    t.index ["subject_id"], name: "index_org_timeline_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id"], name: "index_org_timeline_behaviors_on_subject_type_and_subject_id"
  end

  create_table "scavenger_regional_events", force: :cascade do |t|
  end

  create_table "scavenger_regional_statuses", force: :cascade do |t|
  end

  create_table "scavenger_regionals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.bigint "event_id", default: 0, null: false
    t.datetime "finished_at"
    t.string "idempotency_key", limit: 128, null: false
    t.string "job_type", limit: 64, null: false
    t.datetime "occurred_at"
    t.jsonb "payload"
    t.bigint "region_id", null: false
    t.integer "retry_count"
    t.datetime "started_at"
    t.bigint "status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_scavenger_regionals_on_event_id"
    t.index ["occurred_at"], name: "index_scavenger_regionals_on_occurred_at"
    t.index ["region_id", "idempotency_key"], name: "index_scavenger_regionals_on_region_id_and_idempotency_key", unique: true
    t.index ["region_id", "job_type"], name: "index_scavenger_regionals_on_region_id_and_job_type"
    t.index ["status_id"], name: "index_scavenger_regionals_on_status_id"
  end

  add_foreign_key "app_contact_behaviors", "app_contact_behavior_events", column: "event_id"
  add_foreign_key "app_contact_behaviors", "app_contact_behavior_levels", column: "level_id"
  add_foreign_key "app_document_behaviors", "app_document_behavior_events", column: "event_id"
  add_foreign_key "app_document_behaviors", "app_document_behavior_levels", column: "level_id"
  add_foreign_key "app_timeline_behaviors", "app_timeline_behavior_events", column: "event_id"
  add_foreign_key "app_timeline_behaviors", "app_timeline_behavior_levels", column: "level_id"
  add_foreign_key "com_contact_behaviors", "com_contact_behavior_events", column: "event_id"
  add_foreign_key "com_contact_behaviors", "com_contact_behavior_levels", column: "level_id"
  add_foreign_key "com_document_behaviors", "com_document_behavior_events", column: "event_id"
  add_foreign_key "com_document_behaviors", "com_document_behavior_levels", column: "level_id"
  add_foreign_key "com_timeline_behaviors", "com_timeline_behavior_events", column: "event_id"
  add_foreign_key "com_timeline_behaviors", "com_timeline_behavior_levels", column: "level_id"
  add_foreign_key "org_contact_behaviors", "org_contact_behavior_events", column: "event_id"
  add_foreign_key "org_contact_behaviors", "org_contact_behavior_levels", column: "level_id"
  add_foreign_key "org_document_behaviors", "org_document_behavior_events", column: "event_id"
  add_foreign_key "org_document_behaviors", "org_document_behavior_levels", column: "level_id"
  add_foreign_key "org_timeline_behaviors", "org_timeline_behavior_events", column: "event_id"
  add_foreign_key "org_timeline_behaviors", "org_timeline_behavior_levels", column: "level_id"
  add_foreign_key "scavenger_regionals", "scavenger_regional_events", column: "event_id"
  add_foreign_key "scavenger_regionals", "scavenger_regional_statuses", column: "status_id"
end
