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

ActiveRecord::Schema[8.2].define(version: 2025_12_28_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_timeline_categories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "app_timeline_category_master_id", limit: 255, null: false
    t.uuid "app_timeline_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_timeline_category_master_id"], name: "idx_on_app_timeline_category_master_id_d1179f51ba"
    t.index ["app_timeline_id"], name: "index_app_timeline_categories_unique", unique: true
  end

  create_table "app_timeline_category_masters", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "parent_id", limit: 255, default: "none", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_app_timeline_category_masters_on_parent_id"
  end

  create_table "app_timeline_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_app_timeline_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_app_timeline_statuses_id_format"
  end

  create_table "app_timeline_tag_masters", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "parent_id", limit: 255, default: "none", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_app_timeline_tag_masters_on_parent_id"
  end

  create_table "app_timeline_tags", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "app_timeline_id", null: false
    t.string "app_timeline_tag_master_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_timeline_id", "app_timeline_tag_master_id"], name: "index_app_timeline_tags_unique", unique: true
    t.index ["app_timeline_tag_master_id"], name: "index_app_timeline_tags_on_app_timeline_tag_master_id"
  end

  create_table "app_timeline_versions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "app_timeline_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.string "permalink", limit: 200, null: false
    t.string "public_id", limit: 255, default: "", null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["app_timeline_id", "created_at"], name: "index_app_timeline_versions_on_app_timeline_id_and_created_at"
    t.index ["public_id"], name: "index_app_timeline_versions_on_public_id", unique: true
  end

  create_table "app_timelines", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.string "permalink", limit: 200, null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_app_timelines_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_app_timelines_on_published_at_and_expires_at"
    t.index ["status_id"], name: "index_app_timelines_on_status_id"
  end

  create_table "com_timeline_categories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.string "com_timeline_category_master_id", limit: 255, null: false
    t.uuid "com_timeline_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["com_timeline_category_master_id"], name: "idx_on_com_timeline_category_master_id_3ab8427d3a"
    t.index ["com_timeline_id"], name: "index_com_timeline_categories_unique", unique: true
  end

  create_table "com_timeline_category_masters", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "parent_id", limit: 255, default: "none", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_com_timeline_category_masters_on_parent_id"
  end

  create_table "com_timeline_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_com_timeline_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_com_timeline_statuses_id_format"
  end

  create_table "com_timeline_tag_masters", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "parent_id", limit: 255, default: "none", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_com_timeline_tag_masters_on_parent_id"
  end

  create_table "com_timeline_tags", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "com_timeline_id", null: false
    t.string "com_timeline_tag_master_id", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["com_timeline_id", "com_timeline_tag_master_id"], name: "index_com_timeline_tags_unique", unique: true
    t.index ["com_timeline_tag_master_id"], name: "index_com_timeline_tags_on_com_timeline_tag_master_id"
  end

  create_table "com_timeline_versions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "body"
    t.uuid "com_timeline_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.string "permalink", limit: 200, null: false
    t.string "public_id", limit: 255, default: "", null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["com_timeline_id", "created_at"], name: "index_com_timeline_versions_on_com_timeline_id_and_created_at"
    t.index ["public_id"], name: "index_com_timeline_versions_on_public_id", unique: true
  end

  create_table "com_timelines", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.string "permalink", limit: 200, null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_com_timelines_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_com_timelines_on_published_at_and_expires_at"
    t.index ["status_id"], name: "index_com_timelines_on_status_id"
  end

  create_table "org_timeline_categories", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "org_timeline_category_master_id", limit: 255, null: false
    t.uuid "org_timeline_id", null: false
    t.datetime "updated_at", null: false
    t.index ["org_timeline_category_master_id"], name: "idx_on_org_timeline_category_master_id_fa21cb5b0c"
    t.index ["org_timeline_id"], name: "index_org_timeline_categories_unique", unique: true
  end

  create_table "org_timeline_category_masters", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "parent_id", limit: 255, default: "none", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_org_timeline_category_masters_on_parent_id"
  end

  create_table "org_timeline_statuses", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "description", limit: 255, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index "lower((id)::text)", name: "index_org_timeline_statuses_on_lower_id", unique: true
    t.check_constraint "id IS NULL OR id::text ~ '^[A-Z0-9_]+$'::text", name: "chk_org_timeline_statuses_id_format"
  end

  create_table "org_timeline_tag_masters", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "parent_id", limit: 255, default: "none", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_org_timeline_tag_masters_on_parent_id"
  end

  create_table "org_timeline_tags", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "org_timeline_id", null: false
    t.string "org_timeline_tag_master_id", limit: 255, null: false
    t.datetime "updated_at", null: false
    t.index ["org_timeline_id", "org_timeline_tag_master_id"], name: "index_org_timeline_tags_unique", unique: true
    t.index ["org_timeline_tag_master_id"], name: "index_org_timeline_tags_on_org_timeline_tag_master_id"
  end

  create_table "org_timeline_versions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.uuid "org_timeline_id", null: false
    t.string "permalink", limit: 200, null: false
    t.string "public_id", limit: 255, default: "", null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["org_timeline_id", "created_at"], name: "index_org_timeline_versions_on_org_timeline_id_and_created_at"
    t.index ["public_id"], name: "index_org_timeline_versions_on_public_id", unique: true
  end

  create_table "org_timelines", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.string "permalink", limit: 200, null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", null: false
    t.string "status_id", limit: 255, default: "NONE", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_org_timelines_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_org_timelines_on_published_at_and_expires_at"
    t.index ["status_id"], name: "index_org_timelines_on_status_id"
  end

  add_foreign_key "app_timeline_categories", "app_timeline_category_masters"
  add_foreign_key "app_timeline_categories", "app_timelines", on_delete: :cascade
  add_foreign_key "app_timeline_category_masters", "app_timeline_category_masters", column: "parent_id"
  add_foreign_key "app_timeline_tag_masters", "app_timeline_tag_masters", column: "parent_id"
  add_foreign_key "app_timeline_tags", "app_timeline_tag_masters"
  add_foreign_key "app_timeline_tags", "app_timelines", on_delete: :cascade
  add_foreign_key "app_timeline_versions", "app_timelines", on_delete: :cascade
  add_foreign_key "app_timelines", "app_timeline_statuses", column: "status_id"
  add_foreign_key "com_timeline_categories", "com_timeline_category_masters"
  add_foreign_key "com_timeline_categories", "com_timelines", on_delete: :cascade
  add_foreign_key "com_timeline_category_masters", "com_timeline_category_masters", column: "parent_id"
  add_foreign_key "com_timeline_tag_masters", "com_timeline_tag_masters", column: "parent_id"
  add_foreign_key "com_timeline_tags", "com_timeline_tag_masters"
  add_foreign_key "com_timeline_tags", "com_timelines", on_delete: :cascade
  add_foreign_key "com_timeline_versions", "com_timelines", on_delete: :cascade
  add_foreign_key "com_timelines", "com_timeline_statuses", column: "status_id"
  add_foreign_key "org_timeline_categories", "org_timeline_category_masters"
  add_foreign_key "org_timeline_categories", "org_timelines", on_delete: :cascade
  add_foreign_key "org_timeline_category_masters", "org_timeline_category_masters", column: "parent_id"
  add_foreign_key "org_timeline_tag_masters", "org_timeline_tag_masters", column: "parent_id"
  add_foreign_key "org_timeline_tags", "org_timeline_tag_masters"
  add_foreign_key "org_timeline_tags", "org_timelines", on_delete: :cascade
  add_foreign_key "org_timeline_versions", "org_timelines", on_delete: :cascade
  add_foreign_key "org_timelines", "org_timeline_statuses", column: "status_id"
end
