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

ActiveRecord::Schema[8.2].define(version: 2026_03_08_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "app_preference_colortheme_options", force: :cascade do |t|
  end

  create_table "app_preference_colorthemes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "app_preference_cookies", force: :cascade do |t|
    t.uuid "consent_version"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.bigint "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_app_preference_cookies_on_preference_id", unique: true
  end

  create_table "app_preference_language_options", force: :cascade do |t|
  end

  create_table "app_preference_languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_languages_on_preference_id", unique: true
  end

  create_table "app_preference_region_options", force: :cascade do |t|
  end

  create_table "app_preference_regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_regions_on_preference_id", unique: true
  end

  create_table "app_preference_statuses", force: :cascade do |t|
  end

  create_table "app_preference_timezone_options", force: :cascade do |t|
  end

  create_table "app_preference_timezones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_timezones_on_preference_id", unique: true
  end

  create_table "app_preferences", force: :cascade do |t|
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.string "device_id"
    t.datetime "expires_at"
    t.string "jti"
    t.string "public_id", null: false
    t.bigint "replaced_by_id"
    t.datetime "revoked_at"
    t.bigint "status_id", default: 2, null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["device_id"], name: "index_app_preferences_on_device_id"
    t.index ["jti"], name: "index_app_preferences_on_jti", unique: true
    t.index ["public_id"], name: "index_app_preferences_on_public_id", unique: true
    t.index ["replaced_by_id"], name: "index_app_preferences_on_replaced_by_id"
    t.index ["revoked_at"], name: "index_app_preferences_on_revoked_at"
    t.index ["status_id"], name: "index_app_preferences_on_status_id"
    t.index ["token_digest"], name: "index_app_preferences_on_token_digest"
    t.index ["used_at"], name: "index_app_preferences_on_used_at"
  end

  create_table "com_preference_colortheme_options", force: :cascade do |t|
  end

  create_table "com_preference_colorthemes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "com_preference_cookies", force: :cascade do |t|
    t.uuid "consent_version"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.bigint "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_com_preference_cookies_on_preference_id", unique: true
  end

  create_table "com_preference_language_options", force: :cascade do |t|
  end

  create_table "com_preference_languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_languages_on_preference_id", unique: true
  end

  create_table "com_preference_region_options", force: :cascade do |t|
  end

  create_table "com_preference_regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_regions_on_preference_id", unique: true
  end

  create_table "com_preference_statuses", force: :cascade do |t|
  end

  create_table "com_preference_timezone_options", force: :cascade do |t|
  end

  create_table "com_preference_timezones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_timezones_on_preference_id", unique: true
  end

  create_table "com_preferences", force: :cascade do |t|
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.string "device_id"
    t.datetime "expires_at"
    t.string "jti"
    t.string "public_id", null: false
    t.bigint "replaced_by_id"
    t.datetime "revoked_at"
    t.bigint "status_id", default: 2, null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["device_id"], name: "index_com_preferences_on_device_id"
    t.index ["jti"], name: "index_com_preferences_on_jti", unique: true
    t.index ["public_id"], name: "index_com_preferences_on_public_id", unique: true
    t.index ["replaced_by_id"], name: "index_com_preferences_on_replaced_by_id"
    t.index ["revoked_at"], name: "index_com_preferences_on_revoked_at"
    t.index ["status_id"], name: "index_com_preferences_on_status_id"
    t.index ["token_digest"], name: "index_com_preferences_on_token_digest"
    t.index ["used_at"], name: "index_com_preferences_on_used_at"
  end

  create_table "org_preference_colortheme_options", force: :cascade do |t|
  end

  create_table "org_preference_colorthemes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "org_preference_cookies", force: :cascade do |t|
    t.uuid "consent_version"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.bigint "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_org_preference_cookies_on_preference_id", unique: true
  end

  create_table "org_preference_language_options", force: :cascade do |t|
  end

  create_table "org_preference_languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_languages_on_preference_id", unique: true
  end

  create_table "org_preference_region_options", force: :cascade do |t|
  end

  create_table "org_preference_regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_regions_on_preference_id", unique: true
  end

  create_table "org_preference_statuses", force: :cascade do |t|
  end

  create_table "org_preference_timezone_options", force: :cascade do |t|
  end

  create_table "org_preference_timezones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_timezones_on_preference_id", unique: true
  end

  create_table "org_preferences", force: :cascade do |t|
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.string "device_id"
    t.datetime "expires_at"
    t.string "jti"
    t.string "public_id", null: false
    t.bigint "replaced_by_id"
    t.datetime "revoked_at"
    t.bigint "status_id", default: 2, null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["device_id"], name: "index_org_preferences_on_device_id"
    t.index ["jti"], name: "index_org_preferences_on_jti", unique: true
    t.index ["public_id"], name: "index_org_preferences_on_public_id", unique: true
    t.index ["replaced_by_id"], name: "index_org_preferences_on_replaced_by_id"
    t.index ["revoked_at"], name: "index_org_preferences_on_revoked_at"
    t.index ["status_id"], name: "index_org_preferences_on_status_id"
    t.index ["token_digest"], name: "index_org_preferences_on_token_digest"
    t.index ["used_at"], name: "index_org_preferences_on_used_at"
  end

  create_table "staff_org_preferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigserial "org_preference_id", null: false
    t.bigint "staff_id", null: false
    t.datetime "updated_at", null: false
    t.index ["org_preference_id"], name: "index_staff_org_preferences_on_org_preference_id"
    t.index ["staff_id", "org_preference_id"], name: "index_staff_org_preferences_on_staff_id_and_org_preference_id", unique: true
  end

  create_table "user_app_preferences", force: :cascade do |t|
    t.bigserial "app_preference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["app_preference_id"], name: "index_user_app_preferences_on_app_preference_id"
    t.index ["user_id", "app_preference_id"], name: "index_user_app_preferences_on_user_id_and_app_preference_id", unique: true
  end

  add_foreign_key "app_preference_colorthemes", "app_preference_colortheme_options", column: "option_id", name: "fk_app_preference_colorthemes_on_option_id"
  add_foreign_key "app_preference_colorthemes", "app_preferences", column: "preference_id", validate: false
  add_foreign_key "app_preference_cookies", "app_preferences", column: "preference_id", validate: false
  add_foreign_key "app_preference_languages", "app_preference_language_options", column: "option_id", name: "fk_app_preference_languages_on_option_id"
  add_foreign_key "app_preference_languages", "app_preferences", column: "preference_id", validate: false
  add_foreign_key "app_preference_regions", "app_preference_region_options", column: "option_id", name: "fk_app_preference_regions_on_option_id"
  add_foreign_key "app_preference_regions", "app_preferences", column: "preference_id", validate: false
  add_foreign_key "app_preference_timezones", "app_preference_timezone_options", column: "option_id", name: "fk_app_preference_timezones_on_option_id"
  add_foreign_key "app_preference_timezones", "app_preferences", column: "preference_id", validate: false
  add_foreign_key "app_preferences", "app_preference_statuses", column: "status_id", name: "fk_app_preferences_on_status_id"
  add_foreign_key "app_preferences", "app_preferences", column: "replaced_by_id", on_delete: :nullify, validate: false
  add_foreign_key "com_preference_colorthemes", "com_preference_colortheme_options", column: "option_id", name: "fk_com_preference_colorthemes_on_option_id"
  add_foreign_key "com_preference_colorthemes", "com_preferences", column: "preference_id", validate: false
  add_foreign_key "com_preference_cookies", "com_preferences", column: "preference_id", validate: false
  add_foreign_key "com_preference_languages", "com_preference_language_options", column: "option_id", name: "fk_com_preference_languages_on_option_id"
  add_foreign_key "com_preference_languages", "com_preferences", column: "preference_id", validate: false
  add_foreign_key "com_preference_regions", "com_preference_region_options", column: "option_id", name: "fk_com_preference_regions_on_option_id"
  add_foreign_key "com_preference_regions", "com_preferences", column: "preference_id", validate: false
  add_foreign_key "com_preference_timezones", "com_preference_timezone_options", column: "option_id", name: "fk_com_preference_timezones_on_option_id"
  add_foreign_key "com_preference_timezones", "com_preferences", column: "preference_id", validate: false
  add_foreign_key "com_preferences", "com_preference_statuses", column: "status_id", name: "fk_com_preferences_on_status_id"
  add_foreign_key "com_preferences", "com_preferences", column: "replaced_by_id", on_delete: :nullify, validate: false
  add_foreign_key "org_preference_colorthemes", "org_preference_colortheme_options", column: "option_id", name: "fk_org_preference_colorthemes_on_option_id"
  add_foreign_key "org_preference_colorthemes", "org_preferences", column: "preference_id", validate: false
  add_foreign_key "org_preference_cookies", "org_preferences", column: "preference_id", validate: false
  add_foreign_key "org_preference_languages", "org_preference_language_options", column: "option_id", name: "fk_org_preference_languages_on_option_id"
  add_foreign_key "org_preference_languages", "org_preferences", column: "preference_id", validate: false
  add_foreign_key "org_preference_regions", "org_preference_region_options", column: "option_id", name: "fk_org_preference_regions_on_option_id"
  add_foreign_key "org_preference_regions", "org_preferences", column: "preference_id", validate: false
  add_foreign_key "org_preference_timezones", "org_preference_timezone_options", column: "option_id", name: "fk_org_preference_timezones_on_option_id"
  add_foreign_key "org_preference_timezones", "org_preferences", column: "preference_id", validate: false
  add_foreign_key "org_preferences", "org_preference_statuses", column: "status_id", name: "fk_org_preferences_on_status_id"
  add_foreign_key "org_preferences", "org_preferences", column: "replaced_by_id", on_delete: :nullify, validate: false
  add_foreign_key "staff_org_preferences", "org_preferences", on_delete: :cascade
  add_foreign_key "user_app_preferences", "app_preferences", on_delete: :cascade
end
