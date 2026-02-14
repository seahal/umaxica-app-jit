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

ActiveRecord::Schema[8.2].define(version: 2026_02_13_000001) do
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_contact_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_app_contact_behaviors_on_event_id"
    t.index ["level_id"], name: "index_app_contact_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_document_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_app_document_behaviors_on_event_id"
    t.index ["level_id"], name: "index_app_document_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_app_timeline_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_app_timeline_behaviors_on_event_id"
    t.index ["level_id"], name: "index_app_timeline_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_contact_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_com_contact_behaviors_on_event_id"
    t.index ["level_id"], name: "index_com_contact_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_document_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_com_document_behaviors_on_event_id"
    t.index ["level_id"], name: "index_com_document_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_com_timeline_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_com_timeline_behaviors_on_event_id"
    t.index ["level_id"], name: "index_com_timeline_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_contact_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_org_contact_behaviors_on_event_id"
    t.index ["level_id"], name: "index_org_contact_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_document_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_org_document_behaviors_on_event_id"
    t.index ["level_id"], name: "index_org_document_behaviors_on_level_id"
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
    t.bigint "event_id"
    t.datetime "expires_at"
    t.bigint "level_id"
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "subject_id", null: false
    t.string "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_org_timeline_behaviors_on_actor_type_and_actor_id"
    t.index ["event_id"], name: "index_org_timeline_behaviors_on_event_id"
    t.index ["level_id"], name: "index_org_timeline_behaviors_on_level_id"
    t.index ["subject_type", "subject_id"], name: "index_org_timeline_behaviors_on_subject_type_and_subject_id"
  end
end
