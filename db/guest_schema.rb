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

ActiveRecord::Schema[8.1].define(version: 2025_10_27_125955) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "corporate_site_contact_emails", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "corporate_site_contact_id", null: false
    t.timestamptz "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.string "email_address", limit: 1000, default: "", null: false
    t.timestamptz "expires_at", default: "2025-10-29 13:12:40", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "token_digest", limit: 255
    t.timestamptz "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.timestamptz "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["corporate_site_contact_id"], name: "idx_on_corporate_site_contact_id_885e7bccdf"
    t.index ["email_address"], name: "index_corporate_site_contact_emails_on_email_address"
    t.index ["verifier_expires_at"], name: "index_corporate_site_contact_emails_on_verifier_expires_at"
  end

  create_table "corporate_site_contact_telephones", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "corporate_site_contact_id", null: false
    t.timestamptz "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: "2025-10-29 13:12:40", null: false
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.string "telephone_number", limit: 1000, default: "", null: false
    t.timestamptz "updated_at", null: false
    t.integer "verifier_attempts_left", limit: 2, default: 3, null: false
    t.string "verifier_digest", limit: 255
    t.timestamptz "verifier_expires_at"
    t.index ["corporate_site_contact_id"], name: "idx_on_corporate_site_contact_id_72d0fd0e7a"
    t.index ["telephone_number"], name: "index_corporate_site_contact_telephones_on_telephone_number"
    t.index ["verifier_expires_at"], name: "index_corporate_site_contact_telephones_on_verifier_expires_at"
  end

  create_table "corporate_site_contact_topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "activated", default: false, null: false
    t.uuid "corporate_site_contact_id", null: false
    t.timestamptz "created_at", null: false
    t.boolean "deletable", default: false, null: false
    t.timestamptz "expires_at", default: "2025-10-29 13:12:40", null: false
    t.integer "otp_attempts_left", limit: 2, default: 3, null: false
    t.string "otp_digest", limit: 255
    t.timestamptz "otp_expires_at"
    t.integer "remaining_views", limit: 2, default: 10, null: false
    t.timestamptz "updated_at", null: false
    t.index ["corporate_site_contact_id"], name: "idx_on_corporate_site_contact_id_cdc1fc776f"
  end

  create_table "corporate_site_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category", default: "DEFAULT_VALUE", null: false
    t.timestamptz "created_at", null: false
    t.string "status", default: "DEFAULT_VALUE", null: false
    t.string "token", limit: 32, default: "", null: false
    t.string "token_digest", limit: 255
    t.timestamptz "token_expires_at"
    t.boolean "token_viewed", default: false, null: false
    t.timestamptz "updated_at", null: false
    t.index ["category"], name: "index_corporate_site_contacts_on_category"
    t.index ["status"], name: "index_corporate_site_contacts_on_status"
    t.index ["token"], name: "index_corporate_site_contacts_on_token"
    t.index ["token_digest"], name: "index_corporate_site_contacts_on_token_digest"
    t.index ["token_expires_at"], name: "index_corporate_site_contacts_on_token_expires_at"
  end

  create_table "service_site_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.text "description"
    t.string "email_address"
    t.cidr "ip_address"
    t.string "telephone_number"
    t.string "title"
    t.timestamptz "updated_at", null: false
  end

  create_table "staff_site_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.text "description"
    t.string "email_address"
    t.cidr "ip_address"
    t.string "telephone_number"
    t.string "title"
    t.timestamptz "updated_at", null: false
  end

  add_foreign_key "corporate_site_contact_emails", "corporate_site_contacts"
  add_foreign_key "corporate_site_contact_telephones", "corporate_site_contacts"
  add_foreign_key "corporate_site_contact_topics", "corporate_site_contacts"
end
