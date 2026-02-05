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

ActiveRecord::Schema[8.2].define(version: 2026_02_04_120200) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "app_contact_categories", force: :cascade do |t|
  end

  create_table "app_contact_emails", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "app_contact_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.string "token_digest", limit: 255
    t.timestamptz "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["app_contact_id"], name: "index_app_contact_emails_on_app_contact_id"
    t.index ["email_address"], name: "index_app_contact_emails_on_email_address"
  end

  create_table "app_contact_histories", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.bigint "app_contact_id", null: false
    t.datetime "created_at", null: false
    t.string "event_id", default: "NONE", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["app_contact_id"], name: "index_app_contact_histories_on_app_contact_id"
  end

  create_table "app_contact_statuses", force: :cascade do |t|
  end

  create_table "app_contact_telephones", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "app_contact_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["app_contact_id"], name: "index_app_contact_telephones_on_app_contact_id"
    t.index ["telephone_number"], name: "index_app_contact_telephones_on_telephone_number"
  end

  create_table "app_contact_topics", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "app_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest"
    t.datetime "otp_expires_at"
    t.string "public_id", limit: 21, null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.datetime "updated_at", null: false
    t.index ["app_contact_id"], name: "index_app_contact_topics_on_app_contact_id"
    t.index ["expires_at"], name: "index_app_contact_topics_on_expires_at"
    t.index ["public_id"], name: "index_app_contact_topics_on_public_id", unique: true
  end

  create_table "app_contacts", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.string "public_id", limit: 21, null: false
    t.bigint "status_id", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest"
    t.datetime "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_app_contacts_on_category_id"
    t.index ["public_id"], name: "index_app_contacts_on_public_id", unique: true
    t.index ["status_id"], name: "index_app_contacts_on_status_id"
    t.index ["token"], name: "index_app_contacts_on_token"
    t.index ["token_digest"], name: "index_app_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_app_contacts_on_token_expires_at"
  end

  create_table "com_contact_audits", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.bigint "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.string "event_id", default: "NONE", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["com_contact_id"], name: "index_com_contact_audits_on_com_contact_id"
  end

  create_table "com_contact_categories", force: :cascade do |t|
  end

  create_table "com_contact_emails", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "com_contact_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deletable", default: false, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "hotp_counter"
    t.string "hotp_secret"
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "token_digest", limit: 255
    t.timestamptz "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["com_contact_id"], name: "index_com_contact_emails_on_com_contact_id_unique", unique: true
    t.index ["email_address"], name: "index_com_contact_emails_on_email_address"
  end

  create_table "com_contact_statuses", force: :cascade do |t|
  end

  create_table "com_contact_telephones", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "com_contact_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "hotp_counter"
    t.string "hotp_secret"
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["com_contact_id"], name: "index_com_contact_telephones_on_com_contact_id_unique", unique: true
    t.index ["telephone_number"], name: "index_com_contact_telephones_on_telephone_number"
  end

  create_table "com_contact_topics", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.bigint "com_contact_id", null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.text "description"
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest"
    t.datetime "otp_expires_at"
    t.string "public_id", limit: 21, null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["com_contact_id"], name: "index_com_contact_topics_on_com_contact_id"
    t.index ["expires_at"], name: "index_com_contact_topics_on_expires_at"
    t.index ["public_id"], name: "index_com_contact_topics_on_public_id", unique: true
  end

  create_table "com_contacts", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.string "public_id", limit: 21, null: false
    t.bigint "status_id", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest"
    t.datetime "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_com_contacts_on_category_id"
    t.index ["public_id"], name: "index_com_contacts_on_public_id", unique: true
    t.index ["status_id"], name: "index_com_contacts_on_status_id"
    t.index ["token"], name: "index_com_contacts_on_token"
    t.index ["token_digest"], name: "index_com_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_com_contacts_on_token_expires_at"
  end

  create_table "org_contact_categories", force: :cascade do |t|
  end

  create_table "org_contact_emails", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.bigint "org_contact_id", null: false
    t.string "token_digest", limit: 255
    t.timestamptz "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["email_address"], name: "index_org_contact_emails_on_email_address"
    t.index ["org_contact_id"], name: "index_org_contact_emails_on_org_contact_id"
  end

  create_table "org_contact_histories", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.string "event_id", default: "NONE", null: false
    t.bigint "org_contact_id", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["org_contact_id"], name: "index_org_contact_histories_on_org_contact_id"
  end

  create_table "org_contact_statuses", force: :cascade do |t|
  end

  create_table "org_contact_telephones", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "org_contact_id", null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["org_contact_id"], name: "index_org_contact_telephones_on_org_contact_id"
    t.index ["telephone_number"], name: "index_org_contact_telephones_on_telephone_number"
  end

  create_table "org_contact_topics", force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.datetime "expires_at", default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false
    t.bigint "org_contact_id", null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest"
    t.datetime "otp_expires_at"
    t.string "public_id", limit: 21, null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_org_contact_topics_on_expires_at"
    t.index ["org_contact_id"], name: "index_org_contact_topics_on_org_contact_id"
    t.index ["public_id"], name: "index_org_contact_topics_on_public_id", unique: true
  end

  create_table "org_contacts", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.string "public_id", limit: 21, null: false
    t.bigint "status_id", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest"
    t.datetime "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_org_contacts_on_category_id"
    t.index ["public_id"], name: "index_org_contacts_on_public_id", unique: true
    t.index ["status_id"], name: "index_org_contacts_on_status_id"
    t.index ["token"], name: "index_org_contacts_on_token"
    t.index ["token_digest"], name: "index_org_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_org_contacts_on_token_expires_at"
  end

  add_foreign_key "app_contact_emails", "app_contacts"
  add_foreign_key "app_contact_histories", "app_contacts", validate: false
  add_foreign_key "app_contact_telephones", "app_contacts"
  add_foreign_key "app_contact_topics", "app_contacts", validate: false
  add_foreign_key "app_contacts", "app_contact_categories", column: "category_id"
  add_foreign_key "app_contacts", "app_contact_statuses", column: "status_id", on_delete: :nullify
  add_foreign_key "com_contact_audits", "com_contacts", validate: false
  add_foreign_key "com_contact_emails", "com_contacts"
  add_foreign_key "com_contact_telephones", "com_contacts"
  add_foreign_key "com_contact_topics", "com_contacts", validate: false
  add_foreign_key "com_contacts", "com_contact_categories", column: "category_id"
  add_foreign_key "com_contacts", "com_contact_statuses", column: "status_id", name: "fk_com_contacts_on_status_id_nullify", on_delete: :nullify
  add_foreign_key "org_contact_emails", "org_contacts"
  add_foreign_key "org_contact_histories", "org_contacts", validate: false
  add_foreign_key "org_contact_telephones", "org_contacts"
  add_foreign_key "org_contact_topics", "org_contacts", validate: false
  add_foreign_key "org_contacts", "org_contact_categories", column: "category_id"
  add_foreign_key "org_contacts", "org_contact_statuses", column: "status_id", name: "fk_org_contacts_on_status_id_nullify", on_delete: :nullify
end
