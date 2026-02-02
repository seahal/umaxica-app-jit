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

ActiveRecord::Schema[8.2].define(version: 2026_02_02_230000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", null: false
    t.bigint "staff_message_id"
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_admin_messages_on_public_id", unique: true
    t.index ["staff_message_id"], name: "index_admin_messages_on_staff_message_id"
  end

  create_table "client_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_message_id"
    t.index ["public_id"], name: "index_client_messages_on_public_id", unique: true
    t.index ["user_message_id"], name: "index_client_messages_on_user_message_id"
  end

  create_table "staff_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_staff_messages_on_public_id", unique: true
    t.index ["staff_id"], name: "index_staff_messages_on_staff_id"
  end

  create_table "user_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "public_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["public_id"], name: "index_user_messages_on_public_id", unique: true
    t.index ["user_id"], name: "index_user_messages_on_user_id"
  end

  add_foreign_key "admin_messages", "staff_messages", name: "fk_admin_messages_on_staff_message_id_cascade", on_delete: :cascade
  add_foreign_key "client_messages", "user_messages", name: "fk_client_messages_on_user_message_id_cascade", on_delete: :cascade
end
