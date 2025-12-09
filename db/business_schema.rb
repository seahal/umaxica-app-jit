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

ActiveRecord::Schema[8.2].define(version: 2025_12_09_005000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "app_document_status_id", limit: 255
    t.datetime "created_at", null: false
    t.string "description"
    t.uuid "parent_id"
    t.uuid "prev_id"
    t.uuid "staff_id"
    t.uuid "succ_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "app_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_timelines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "app_timeline_status_id", limit: 255
    t.datetime "created_at", null: false
    t.string "description"
    t.uuid "parent_id"
    t.uuid "prev_id"
    t.uuid "staff_id"
    t.uuid "succ_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "com_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "com_document_status_id", limit: 255
    t.datetime "created_at", null: false
    t.string "description"
    t.uuid "parent_id"
    t.uuid "prev_id"
    t.uuid "staff_id"
    t.uuid "succ_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "com_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "com_timelines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "com_timeline_status_id", limit: 255
    t.datetime "created_at", null: false
    t.string "description"
    t.uuid "parent_id"
    t.uuid "prev_id"
    t.uuid "staff_id"
    t.uuid "succ_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "entity_statuses", id: :string, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "org_document_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "org_document_status_id", limit: 255
    t.uuid "parent_id"
    t.uuid "prev_id"
    t.uuid "staff_id"
    t.uuid "succ_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "org_timeline_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "org_timelines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "org_timeline_status_id", limit: 255
    t.uuid "parent_id"
    t.uuid "prev_id"
    t.uuid "staff_id"
    t.uuid "succ_id"
    t.string "title"
    t.datetime "updated_at", null: false
  end
end
