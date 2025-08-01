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

ActiveRecord::Schema[8.0].define(version: 2025_04_24_163410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "documents", force: :cascade do |t|
    t.binary "parent_id"
    t.binary "prev_id"
    t.binary "succ_id"
    t.string "title"
    t.string "description"
    t.string "entity_status_id"
    t.binary "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entity_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timelines", force: :cascade do |t|
    t.binary "parent_id"
    t.binary "succ_id"
    t.binary "prev_id"
    t.string "title"
    t.string "description"
    t.string "entity_status_id"
    t.binary "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
