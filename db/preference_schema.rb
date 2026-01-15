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

ActiveRecord::Schema[8.2].define(version: 2026_01_14_174717) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_preference_colortheme_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "app_preference_colortheme_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "app_preference_colortheme_options_position_positive"
  end

  create_table "app_preference_colorthemes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "app_preference_cookies", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "consent_version_id"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.uuid "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["consent_version_id"], name: "index_app_preference_cookies_on_consent_version_id"
    t.index ["preference_id"], name: "index_app_preference_cookies_on_preference_id", unique: true
  end

  create_table "app_preference_language_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "app_preference_language_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "app_preference_language_options_position_positive"
  end

  create_table "app_preference_languages", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_languages_on_preference_id", unique: true
  end

  create_table "app_preference_region_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "app_preference_region_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "app_preference_region_options_position_positive"
  end

  create_table "app_preference_regions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_regions_on_preference_id", unique: true
  end

  create_table "app_preference_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "app_preference_statuses_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "app_preference_statuses_position_positive"
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "app_preference_statuses_id_format_check"
  end

  create_table "app_preference_timezone_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "app_preference_timezone_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "app_preference_timezone_options_position_positive"
  end

  create_table "app_preference_timezones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_app_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_app_preference_timezones_on_preference_id", unique: true
  end

  create_table "app_preferences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "jti"
    t.integer "lock_version", default: 0, null: false
    t.string "public_id"
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_app_preferences_on_jti", unique: true
    t.index ["status_id"], name: "index_app_preferences_on_status_id"
  end

  create_table "com_preference_colortheme_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "com_preference_colortheme_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "com_preference_colortheme_options_position_positive"
  end

  create_table "com_preference_colorthemes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "com_preference_cookies", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "consent_version_id"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.uuid "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["consent_version_id"], name: "index_com_preference_cookies_on_consent_version_id"
    t.index ["preference_id"], name: "index_com_preference_cookies_on_preference_id", unique: true
  end

  create_table "com_preference_language_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "com_preference_language_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "com_preference_language_options_position_positive"
  end

  create_table "com_preference_languages", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_languages_on_preference_id", unique: true
  end

  create_table "com_preference_region_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "com_preference_region_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "com_preference_region_options_position_positive"
  end

  create_table "com_preference_regions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_regions_on_preference_id", unique: true
  end

  create_table "com_preference_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "com_preference_statuses_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "com_preference_statuses_position_positive"
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "com_preference_statuses_id_format_check"
  end

  create_table "com_preference_timezone_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "com_preference_timezone_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "com_preference_timezone_options_position_positive"
  end

  create_table "com_preference_timezones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_com_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_com_preference_timezones_on_preference_id", unique: true
  end

  create_table "com_preferences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "jti"
    t.integer "lock_version", default: 0, null: false
    t.string "public_id"
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_com_preferences_on_jti", unique: true
    t.index ["status_id"], name: "index_com_preferences_on_status_id"
  end

  create_table "org_preference_colortheme_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "org_preference_colortheme_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "org_preference_colortheme_options_position_positive"
  end

  create_table "org_preference_colorthemes", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "org_preference_cookies", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "consent_version_id"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.uuid "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["consent_version_id"], name: "index_org_preference_cookies_on_consent_version_id"
    t.index ["preference_id"], name: "index_org_preference_cookies_on_preference_id", unique: true
  end

  create_table "org_preference_language_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "org_preference_language_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "org_preference_language_options_position_positive"
  end

  create_table "org_preference_languages", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_languages_on_preference_id", unique: true
  end

  create_table "org_preference_region_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "org_preference_region_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "org_preference_region_options_position_positive"
  end

  create_table "org_preference_regions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_regions_on_preference_id", unique: true
  end

  create_table "org_preference_statuses", id: { type: :string, limit: 255, default: "NEYO" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "org_preference_statuses_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "org_preference_statuses_position_positive"
    t.check_constraint "id::text ~ '^[A-Z0-9_]+$'::text", name: "org_preference_statuses_id_format_check"
  end

  create_table "org_preference_timezone_options", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "org_preference_timezone_options_position_unique", unique: true
    t.check_constraint "\"position\" > 0", name: "org_preference_timezone_options_position_positive"
  end

  create_table "org_preference_timezones", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_id"
    t.uuid "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_org_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_org_preference_timezones_on_preference_id", unique: true
  end

  create_table "org_preferences", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "jti"
    t.integer "lock_version", default: 0, null: false
    t.string "public_id"
    t.string "status_id", limit: 255, default: "NEYO", null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_org_preferences_on_jti", unique: true
    t.index ["status_id"], name: "index_org_preferences_on_status_id"
  end

  add_foreign_key "app_preference_colorthemes", "app_preference_colortheme_options", column: "option_id"
  add_foreign_key "app_preference_colorthemes", "app_preferences", column: "preference_id"
  add_foreign_key "app_preference_cookies", "app_preferences", column: "preference_id"
  add_foreign_key "app_preference_languages", "app_preference_language_options", column: "option_id"
  add_foreign_key "app_preference_languages", "app_preferences", column: "preference_id"
  add_foreign_key "app_preference_regions", "app_preference_region_options", column: "option_id"
  add_foreign_key "app_preference_regions", "app_preferences", column: "preference_id"
  add_foreign_key "app_preference_timezones", "app_preference_timezone_options", column: "option_id"
  add_foreign_key "app_preference_timezones", "app_preferences", column: "preference_id"
  add_foreign_key "com_preference_colorthemes", "com_preference_colortheme_options", column: "option_id"
  add_foreign_key "com_preference_colorthemes", "com_preferences", column: "preference_id"
  add_foreign_key "com_preference_cookies", "com_preferences", column: "preference_id"
  add_foreign_key "com_preference_languages", "com_preference_language_options", column: "option_id"
  add_foreign_key "com_preference_languages", "com_preferences", column: "preference_id"
  add_foreign_key "com_preference_regions", "com_preference_region_options", column: "option_id"
  add_foreign_key "com_preference_regions", "com_preferences", column: "preference_id"
  add_foreign_key "com_preference_timezones", "com_preference_timezone_options", column: "option_id"
  add_foreign_key "com_preference_timezones", "com_preferences", column: "preference_id"
  add_foreign_key "org_preference_colorthemes", "org_preference_colortheme_options", column: "option_id"
  add_foreign_key "org_preference_colorthemes", "org_preferences", column: "preference_id"
  add_foreign_key "org_preference_cookies", "org_preferences", column: "preference_id"
  add_foreign_key "org_preference_languages", "org_preference_language_options", column: "option_id"
  add_foreign_key "org_preference_languages", "org_preferences", column: "preference_id"
  add_foreign_key "org_preference_regions", "org_preference_region_options", column: "option_id"
  add_foreign_key "org_preference_regions", "org_preferences", column: "preference_id"
  add_foreign_key "org_preference_timezones", "org_preference_timezone_options", column: "option_id"
  add_foreign_key "org_preference_timezones", "org_preferences", column: "preference_id"
end
