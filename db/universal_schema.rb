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
  enable_extension "pgcrypto"

  create_table "area_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_area_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_area_occurrence_statuses_id_format"
  end

  create_table "area_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_area_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_area_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_area_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_area_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_area_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_area_occurrences_public_id_format"
  end

  create_table "domain_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_domain_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_domain_occurrence_statuses_id_format"
  end

  create_table "domain_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 253, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_domain_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_domain_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_domain_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_domain_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_domain_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_domain_occurrences_public_id_format"
  end

  create_table "email_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_email_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_email_occurrence_statuses_id_format"
  end

  create_table "email_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 255, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_email_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_email_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_email_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_email_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_email_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_email_occurrences_public_id_format"
  end

  create_table "ip_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_ip_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_ip_occurrence_statuses_id_format"
  end

  create_table "ip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 64, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_ip_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_ip_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_ip_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_ip_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_ip_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_ip_occurrences_public_id_format"
  end

  create_table "staff_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_staff_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_staff_occurrence_statuses_id_format"
  end

  create_table "staff_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 36, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_staff_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_staff_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_staff_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_staff_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_staff_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_staff_occurrences_public_id_format"
  end

  create_table "telephone_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_telephone_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_telephone_occurrence_statuses_id_format"
  end

  create_table "telephone_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 32, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_telephone_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_telephone_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_telephone_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_telephone_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_telephone_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_telephone_occurrences_public_id_format"
  end

  create_table "user_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_user_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_user_occurrence_statuses_id_format"
  end

  create_table "user_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 36, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_user_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_user_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_user_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_user_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_user_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_user_occurrences_public_id_format"
  end

  create_table "zip_occurrence_statuses", id: { type: :string, limit: 255, default: "NONE" }, force: :cascade do |t|
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.index ["expires_at"], name: "index_zip_occurrence_statuses_on_expires_at"
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_zip_occurrence_statuses_id_format"
  end

  create_table "zip_occurrences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "body", limit: 16, default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }, null: false
    t.string "memo", limit: 1024, default: "", null: false
    t.string "public_id", limit: 21, default: "", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["body"], name: "index_zip_occurrences_on_body", unique: true
    t.index ["expires_at"], name: "index_zip_occurrences_on_expires_at"
    t.index ["public_id"], name: "index_zip_occurrences_on_public_id", unique: true
    t.index ["status_id"], name: "index_zip_occurrences_on_status_id"
    t.check_constraint "char_length(public_id::text) = 21", name: "chk_zip_occurrences_public_id_length"
    t.check_constraint "public_id::text ~ '^[A-Za-z0-9_-]{21}$'::text", name: "chk_zip_occurrences_public_id_format"
  end
end
