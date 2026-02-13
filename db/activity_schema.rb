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

ActiveRecord::Schema[8.2].define(version: 2026_02_13_010002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "app_contact_behavior_events", force: :cascade do |t|
  end

  create_table "app_contact_behavior_levels", force: :cascade do |t|
  end

  create_table "app_contact_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "parent_id", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_contact_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_contact_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_app_contact_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_app_contact_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_app_contact_behaviors_on_occurred_at"
    t.index ["parent_id"], name: "index_app_contact_behaviors_on_parent_id"
    t.index ["subject_id"], name: "index_app_contact_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_4cc6ad33bc"
    t.check_constraint "event_id >= 0", name: "app_contact_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "app_contact_behaviors_level_id_non_negative_check"
  end

  create_table "app_document_behavior_events", force: :cascade do |t|
  end

  create_table "app_document_behavior_levels", force: :cascade do |t|
  end

  create_table "app_document_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_document_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_document_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_app_document_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_app_document_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_app_document_behaviors_on_occurred_at"
    t.index ["subject_id"], name: "index_app_document_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_9aaf743787"
    t.check_constraint "event_id >= 0", name: "app_document_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "app_document_behaviors_level_id_non_negative_check"
  end

  create_table "app_preference_activities", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_preference_activities_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_preference_activities_on_event_id"
    t.index ["expires_at"], name: "index_app_preference_activities_on_expires_at"
    t.index ["level_id"], name: "index_app_preference_activities_on_level_id"
    t.index ["occurred_at"], name: "index_app_preference_activities_on_occurred_at"
    t.index ["subject_id"], name: "index_app_preference_activities_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_app_pref"
    t.check_constraint "event_id >= 0", name: "app_preference_activities_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "app_preference_activities_level_id_non_negative_check"
  end

  create_table "app_preference_activity_events", force: :cascade do |t|
  end

  create_table "app_preference_activity_levels", force: :cascade do |t|
  end

  create_table "app_timeline_behavior_events", force: :cascade do |t|
  end

  create_table "app_timeline_behavior_levels", force: :cascade do |t|
  end

  create_table "app_timeline_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_app_timeline_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_app_timeline_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_app_timeline_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_app_timeline_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_app_timeline_behaviors_on_occurred_at"
    t.index ["subject_id"], name: "index_app_timeline_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_72b011a3db"
    t.check_constraint "event_id >= 0", name: "app_timeline_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "app_timeline_behaviors_level_id_non_negative_check"
  end

  create_table "com_contact_behavior_events", force: :cascade do |t|
  end

  create_table "com_contact_behavior_levels", force: :cascade do |t|
  end

  create_table "com_contact_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "parent_id", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_contact_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_contact_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_com_contact_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_com_contact_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_com_contact_behaviors_on_occurred_at"
    t.index ["parent_id"], name: "index_com_contact_behaviors_on_parent_id"
    t.index ["subject_id"], name: "index_com_contact_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_c1d0a622dc"
    t.check_constraint "event_id >= 0", name: "com_contact_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "com_contact_behaviors_level_id_non_negative_check"
  end

  create_table "com_document_behavior_events", force: :cascade do |t|
  end

  create_table "com_document_behavior_levels", force: :cascade do |t|
  end

  create_table "com_document_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_document_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_document_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_com_document_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_com_document_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_com_document_behaviors_on_occurred_at"
    t.index ["subject_id"], name: "index_com_document_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_6a22ab86d6"
    t.check_constraint "event_id >= 0", name: "com_document_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "com_document_behaviors_level_id_non_negative_check"
  end

  create_table "com_preference_activities", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_preference_activities_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_preference_activities_on_event_id"
    t.index ["expires_at"], name: "index_com_preference_activities_on_expires_at"
    t.index ["level_id"], name: "index_com_preference_activities_on_level_id"
    t.index ["occurred_at"], name: "index_com_preference_activities_on_occurred_at"
    t.index ["subject_id"], name: "index_com_preference_activities_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_com_pref"
    t.check_constraint "event_id >= 0", name: "com_preference_activities_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "com_preference_activities_level_id_non_negative_check"
  end

  create_table "com_preference_activity_events", force: :cascade do |t|
  end

  create_table "com_preference_activity_levels", force: :cascade do |t|
  end

  create_table "com_timeline_behavior_events", force: :cascade do |t|
  end

  create_table "com_timeline_behavior_levels", force: :cascade do |t|
  end

  create_table "com_timeline_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_com_timeline_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_com_timeline_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_com_timeline_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_com_timeline_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_com_timeline_behaviors_on_occurred_at"
    t.index ["subject_id"], name: "index_com_timeline_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_cbca2c0dea"
    t.check_constraint "event_id >= 0", name: "com_timeline_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "com_timeline_behaviors_level_id_non_negative_check"
  end

  create_table "org_contact_behavior_events", force: :cascade do |t|
  end

  create_table "org_contact_behavior_levels", force: :cascade do |t|
  end

  create_table "org_contact_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "parent_id", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_contact_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_contact_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_org_contact_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_org_contact_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_org_contact_behaviors_on_occurred_at"
    t.index ["parent_id"], name: "index_org_contact_behaviors_on_parent_id"
    t.index ["subject_id"], name: "index_org_contact_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_cce97f7f83"
    t.check_constraint "event_id >= 0", name: "org_contact_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "org_contact_behaviors_level_id_non_negative_check"
  end

  create_table "org_document_behavior_events", force: :cascade do |t|
  end

  create_table "org_document_behavior_levels", force: :cascade do |t|
  end

  create_table "org_document_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_document_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_document_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_org_document_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_org_document_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_org_document_behaviors_on_occurred_at"
    t.index ["subject_id"], name: "index_org_document_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_f6fc919b48"
    t.check_constraint "event_id >= 0", name: "org_document_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "org_document_behaviors_level_id_non_negative_check"
  end

  create_table "org_preference_activities", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_preference_activities_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_preference_activities_on_event_id"
    t.index ["expires_at"], name: "index_org_preference_activities_on_expires_at"
    t.index ["level_id"], name: "index_org_preference_activities_on_level_id"
    t.index ["occurred_at"], name: "index_org_preference_activities_on_occurred_at"
    t.index ["subject_id"], name: "index_org_preference_activities_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_org_pref"
    t.check_constraint "event_id >= 0", name: "org_preference_activities_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "org_preference_activities_level_id_non_negative_check"
  end

  create_table "org_preference_activity_events", force: :cascade do |t|
  end

  create_table "org_preference_activity_levels", force: :cascade do |t|
  end

  create_table "org_timeline_behavior_events", force: :cascade do |t|
  end

  create_table "org_timeline_behavior_levels", force: :cascade do |t|
  end

  create_table "org_timeline_behaviors", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_org_timeline_behaviors_on_actor_id_and_occurred_at"
    t.index ["event_id"], name: "index_org_timeline_behaviors_on_event_id"
    t.index ["expires_at"], name: "index_org_timeline_behaviors_on_expires_at"
    t.index ["level_id"], name: "index_org_timeline_behaviors_on_level_id"
    t.index ["occurred_at"], name: "index_org_timeline_behaviors_on_occurred_at"
    t.index ["subject_id"], name: "index_org_timeline_behaviors_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_6bcd25f20a"
    t.check_constraint "event_id >= 0", name: "org_timeline_behaviors_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "org_timeline_behaviors_level_id_non_negative_check"
  end

  create_table "staff_activities", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_staff_activities_on_actor_id_and_occurred_at"
    t.index ["actor_type", "actor_id"], name: "index_staff_activities_on_actor"
    t.index ["event_id"], name: "index_staff_activities_on_event_id"
    t.index ["expires_at"], name: "index_staff_activities_on_expires_at"
    t.index ["level_id"], name: "index_staff_activities_on_level_id"
    t.index ["occurred_at"], name: "index_staff_activities_on_occurred_at"
    t.index ["subject_id"], name: "index_staff_activities_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_2e96c29236"
    t.check_constraint "event_id >= 0", name: "staff_activities_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "staff_activities_level_id_non_negative_check"
  end

  create_table "staff_activity_events", force: :cascade do |t|
  end

  create_table "staff_activity_levels", force: :cascade do |t|
  end

  create_table "user_activities", force: :cascade do |t|
    t.bigint "actor_id", default: 0, null: false
    t.text "actor_type", default: "", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.text "current_value", default: "", null: false
    t.bigint "event_id", default: 0, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.inet "ip_address", default: "0.0.0.0", null: false
    t.bigint "level_id", default: 0, null: false
    t.datetime "occurred_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "previous_value", default: "", null: false
    t.bigint "subject_id", null: false
    t.text "subject_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "occurred_at"], name: "index_user_activities_on_actor_id_and_occurred_at"
    t.index ["actor_type", "actor_id"], name: "index_user_activities_on_actor"
    t.index ["event_id"], name: "index_user_activities_on_event_id"
    t.index ["expires_at"], name: "index_user_activities_on_expires_at"
    t.index ["level_id"], name: "index_user_activities_on_level_id"
    t.index ["occurred_at"], name: "index_user_activities_on_occurred_at"
    t.index ["subject_id"], name: "index_user_activities_on_subject_id"
    t.index ["subject_type", "subject_id", "occurred_at"], name: "idx_on_subject_type_subject_id_occurred_at_a29eb711dd"
    t.check_constraint "event_id >= 0", name: "user_activities_event_id_non_negative_check"
    t.check_constraint "level_id >= 0", name: "user_activities_level_id_non_negative_check"
  end

  create_table "user_activity_events", force: :cascade do |t|
  end

  create_table "user_activity_levels", force: :cascade do |t|
  end

  add_foreign_key "app_contact_behaviors", "app_contact_behavior_events", column: "event_id", validate: false
  add_foreign_key "app_contact_behaviors", "app_contact_behavior_levels", column: "level_id", validate: false
  add_foreign_key "app_document_behaviors", "app_document_behavior_events", column: "event_id", validate: false
  add_foreign_key "app_document_behaviors", "app_document_behavior_levels", column: "level_id", validate: false
  add_foreign_key "app_preference_activities", "app_preference_activity_events", column: "event_id", validate: false
  add_foreign_key "app_preference_activities", "app_preference_activity_levels", column: "level_id", validate: false
  add_foreign_key "app_timeline_behaviors", "app_timeline_behavior_events", column: "event_id", validate: false
  add_foreign_key "app_timeline_behaviors", "app_timeline_behavior_levels", column: "level_id", validate: false
  add_foreign_key "com_contact_behaviors", "com_contact_behavior_events", column: "event_id", validate: false
  add_foreign_key "com_contact_behaviors", "com_contact_behavior_levels", column: "level_id", validate: false
  add_foreign_key "com_document_behaviors", "com_document_behavior_events", column: "event_id", validate: false
  add_foreign_key "com_document_behaviors", "com_document_behavior_levels", column: "level_id", validate: false
  add_foreign_key "com_preference_activities", "com_preference_activity_events", column: "event_id", validate: false
  add_foreign_key "com_preference_activities", "com_preference_activity_levels", column: "level_id", validate: false
  add_foreign_key "com_timeline_behaviors", "com_timeline_behavior_events", column: "event_id", validate: false
  add_foreign_key "com_timeline_behaviors", "com_timeline_behavior_levels", column: "level_id", validate: false
  add_foreign_key "org_contact_behaviors", "org_contact_behavior_events", column: "event_id", validate: false
  add_foreign_key "org_contact_behaviors", "org_contact_behavior_levels", column: "level_id", validate: false
  add_foreign_key "org_document_behaviors", "org_document_behavior_events", column: "event_id", validate: false
  add_foreign_key "org_document_behaviors", "org_document_behavior_levels", column: "level_id", validate: false
  add_foreign_key "org_preference_activities", "org_preference_activity_events", column: "event_id", validate: false
  add_foreign_key "org_preference_activities", "org_preference_activity_levels", column: "level_id", validate: false
  add_foreign_key "org_timeline_behaviors", "org_timeline_behavior_events", column: "event_id", validate: false
  add_foreign_key "org_timeline_behaviors", "org_timeline_behavior_levels", column: "level_id", validate: false
  add_foreign_key "staff_activities", "staff_activity_events", column: "event_id", validate: false
  add_foreign_key "staff_activities", "staff_activity_levels", column: "level_id", validate: false
  add_foreign_key "user_activities", "user_activity_events", column: "event_id", validate: false
  add_foreign_key "user_activities", "user_activity_levels", column: "level_id", validate: false
end
