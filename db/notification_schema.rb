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

ActiveRecord::Schema[8.2].define(version: 2026_01_02_035354) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_notifications", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "staff_notification_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_notification_id"], name: "index_admin_notifications_on_staff_notification_id"
  end

  create_table "client_notifications", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_notification_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.index ["user_notification_id"], name: "index_client_notifications_on_user_notification_id"
  end

  create_table "staff_notifications", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.uuid "staff_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_notifications_on_staff_id"
  end

  create_table "user_notifications", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", default: "00000000-0000-0000-0000-000000000000", null: false
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  add_foreign_key "admin_notifications", "staff_notifications"
  add_foreign_key "client_notifications", "user_notifications"
end
