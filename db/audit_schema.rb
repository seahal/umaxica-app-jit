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

ActiveRecord::Schema[8.2].define(version: 2026_01_07_134926) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_preference_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_preference_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "com_preference_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_preference_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "org_preference_audit_events", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_preference_audit_levels", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
end
