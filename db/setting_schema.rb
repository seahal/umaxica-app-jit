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

ActiveRecord::Schema[8.2].define(version: 2026_04_14_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "settings_preference_activities", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.string "actor_type"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.bigint "preference_id", null: false
    t.index ["actor_type", "actor_id"], name: "index_settings_preference_activities_on_actor"
    t.index ["created_at"], name: "index_settings_preference_activities_on_created_at"
    t.index ["preference_id"], name: "index_settings_preference_activities_on_preference_id"
  end

  create_table "settings_preference_binding_methods", force: :cascade do |t|
  end

  create_table "settings_preference_colortheme_options", force: :cascade do |t|
  end

  create_table "settings_preference_colorthemes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_settings_preference_colorthemes_on_option_id"
    t.index ["preference_id"], name: "index_settings_preference_colorthemes_on_preference_id", unique: true
  end

  create_table "settings_preference_cookies", force: :cascade do |t|
    t.uuid "consent_version"
    t.boolean "consented", default: false, null: false
    t.datetime "consented_at"
    t.datetime "created_at", null: false
    t.boolean "functional", default: false, null: false
    t.boolean "performant", default: false, null: false
    t.bigint "preference_id", null: false
    t.boolean "targetable", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_settings_preference_cookies_on_preference_id", unique: true
  end

  create_table "settings_preference_dbsc_statuses", force: :cascade do |t|
  end

  create_table "settings_preference_language_options", force: :cascade do |t|
  end

  create_table "settings_preference_languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_settings_preference_languages_on_option_id"
    t.index ["preference_id"], name: "index_settings_preference_languages_on_preference_id", unique: true
  end

  create_table "settings_preference_region_options", force: :cascade do |t|
  end

  create_table "settings_preference_regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_settings_preference_regions_on_option_id"
    t.index ["preference_id"], name: "index_settings_preference_regions_on_preference_id", unique: true
  end

  create_table "settings_preference_statuses", force: :cascade do |t|
  end

  create_table "settings_preference_timezone_options", force: :cascade do |t|
  end

  create_table "settings_preference_timezones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_id"], name: "index_settings_preference_timezones_on_option_id"
    t.index ["preference_id"], name: "index_settings_preference_timezones_on_preference_id", unique: true
  end

  create_table "settings_preferences", force: :cascade do |t|
    t.bigint "binding_method_id", default: 0, null: false
    t.datetime "compromised_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.text "dbsc_challenge"
    t.datetime "dbsc_challenge_issued_at"
    t.jsonb "dbsc_public_key"
    t.string "dbsc_session_id"
    t.bigint "dbsc_status_id", default: 0, null: false
    t.datetime "deletable_at"
    t.string "device_id"
    t.string "device_id_digest"
    t.datetime "expires_at"
    t.string "jti"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "public_id", null: false
    t.bigint "replaced_by_id"
    t.datetime "revoked_at"
    t.datetime "shreddable_at"
    t.bigint "staff_id"
    t.bigint "status_id", default: 0, null: false
    t.binary "token_digest"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.bigint "user_id"
    t.index ["binding_method_id"], name: "index_settings_preferences_on_binding_method_id"
    t.index ["customer_id"], name: "index_settings_preferences_on_customer_id_unique", unique: true, where: "(customer_id IS NOT NULL)"
    t.index ["dbsc_session_id"], name: "index_settings_preferences_on_dbsc_session_id", unique: true
    t.index ["dbsc_status_id"], name: "index_settings_preferences_on_dbsc_status_id"
    t.index ["deletable_at"], name: "index_settings_preferences_on_deletable_at"
    t.index ["device_id"], name: "index_settings_preferences_on_device_id"
    t.index ["device_id_digest"], name: "index_settings_preferences_on_device_id_digest"
    t.index ["jti"], name: "index_settings_preferences_on_jti", unique: true
    t.index ["owner_type", "owner_id", "status_id"], name: "index_settings_preferences_on_owner_and_status"
    t.index ["owner_type", "owner_id"], name: "index_settings_preferences_on_owner_type_and_owner_id", unique: true
    t.index ["public_id"], name: "index_settings_preferences_on_public_id", unique: true
    t.index ["replaced_by_id"], name: "index_settings_preferences_on_replaced_by_id"
    t.index ["revoked_at"], name: "index_settings_preferences_on_revoked_at"
    t.index ["shreddable_at"], name: "index_settings_preferences_on_shreddable_at"
    t.index ["staff_id"], name: "index_settings_preferences_on_staff_id_unique", unique: true, where: "(staff_id IS NOT NULL)"
    t.index ["status_id"], name: "index_settings_preferences_on_status_id"
    t.index ["token_digest"], name: "index_settings_preferences_on_token_digest"
    t.index ["used_at"], name: "index_settings_preferences_on_used_at"
    t.index ["user_id"], name: "index_settings_preferences_on_user_id_unique", unique: true, where: "(user_id IS NOT NULL)"
    t.check_constraint "((user_id IS NOT NULL)::integer + (staff_id IS NOT NULL)::integer + (customer_id IS NOT NULL)::integer) = 1", name: "chk_settings_preferences_exactly_one_owner"
  end

  add_foreign_key "settings_preference_activities", "settings_preferences", column: "preference_id", name: "fk_settings_preference_activities_on_preference_id", validate: false
  add_foreign_key "settings_preference_colorthemes", "settings_preference_colortheme_options", column: "option_id", name: "fk_settings_preference_colorthemes_on_option_id", validate: false
  add_foreign_key "settings_preference_colorthemes", "settings_preferences", column: "preference_id", name: "fk_settings_preference_colorthemes_on_preference_id", validate: false
  add_foreign_key "settings_preference_cookies", "settings_preferences", column: "preference_id", name: "fk_settings_preference_cookies_on_preference_id", validate: false
  add_foreign_key "settings_preference_languages", "settings_preference_language_options", column: "option_id", name: "fk_settings_preference_languages_on_option_id", validate: false
  add_foreign_key "settings_preference_languages", "settings_preferences", column: "preference_id", name: "fk_settings_preference_languages_on_preference_id", validate: false
  add_foreign_key "settings_preference_regions", "settings_preference_region_options", column: "option_id", name: "fk_settings_preference_regions_on_option_id", validate: false
  add_foreign_key "settings_preference_regions", "settings_preferences", column: "preference_id", name: "fk_settings_preference_regions_on_preference_id", validate: false
  add_foreign_key "settings_preference_timezones", "settings_preference_timezone_options", column: "option_id", name: "fk_settings_preference_timezones_on_option_id", validate: false
  add_foreign_key "settings_preference_timezones", "settings_preferences", column: "preference_id", name: "fk_settings_preference_timezones_on_preference_id", validate: false
  add_foreign_key "settings_preferences", "settings_preference_binding_methods", column: "binding_method_id", name: "fk_settings_preferences_on_binding_method_id", validate: false
  add_foreign_key "settings_preferences", "settings_preference_dbsc_statuses", column: "dbsc_status_id", name: "fk_settings_preferences_on_dbsc_status_id", validate: false
  add_foreign_key "settings_preferences", "settings_preference_statuses", column: "status_id", name: "fk_settings_preferences_on_status_id", validate: false
  add_foreign_key "settings_preferences", "settings_preferences", column: "replaced_by_id", on_delete: :nullify, validate: false
end
