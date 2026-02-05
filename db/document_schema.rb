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

ActiveRecord::Schema[8.2].define(version: 2026_02_05_160002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "app_document_categories", force: :cascade do |t|
    t.bigint "app_document_category_master_id", default: 0, null: false
    t.bigint "app_document_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_document_category_master_id"], name: "idx_on_app_document_category_master_id_018a74a5ab"
    t.index ["app_document_id"], name: "index_app_document_categories_on_app_document_id", unique: true
    t.check_constraint "app_document_category_master_id >= 0", name: "app_document_categories_app_document_category_master_id_non_neg"
  end

  create_table "app_document_category_masters", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.index ["parent_id"], name: "index_app_document_category_masters_on_parent_id"
  end

  create_table "app_document_revisions", force: :cascade do |t|
    t.bigint "app_document_id", null: false
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
    t.index ["app_document_id", "created_at"], name: "index_app_document_revisions_on_app_document_id_and_created_at"
    t.index ["edited_by_id"], name: "index_app_document_revisions_on_edited_by_id"
    t.index ["public_id"], name: "index_app_document_revisions_on_public_id", unique: true
  end

  create_table "app_document_statuses", force: :cascade do |t|
  end

  create_table "app_document_tag_masters", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.index ["parent_id"], name: "index_app_document_tag_masters_on_parent_id"
  end

  create_table "app_document_tags", force: :cascade do |t|
    t.bigint "app_document_id", null: false
    t.bigint "app_document_tag_master_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_document_id"], name: "index_app_document_tags_on_app_document_id"
    t.index ["app_document_tag_master_id", "app_document_id"], name: "idx_app_document_tags_on_master_and_document", unique: true
    t.check_constraint "app_document_tag_master_id >= 0", name: "app_document_tags_app_document_tag_master_id_non_negative"
  end

  create_table "app_document_versions", force: :cascade do |t|
    t.bigint "app_document_id", null: false
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
    t.index ["app_document_id", "created_at"], name: "index_app_document_versions_on_app_document_id_and_created_at"
    t.index ["edited_by_id"], name: "index_app_document_versions_on_edited_by_id"
    t.index ["public_id"], name: "index_app_document_versions_on_public_id", unique: true
  end

  create_table "app_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.bigint "latest_revision_id"
    t.bigint "latest_version_id"
    t.integer "lock_version", default: 0, null: false
    t.string "permalink", limit: 200, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", default: "", null: false
    t.string "slug_id", limit: 32, default: "", null: false
    t.bigint "status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["latest_revision_id"], name: "index_app_documents_on_latest_revision_id", unique: true
    t.index ["latest_version_id"], name: "index_app_documents_on_latest_version_id", unique: true
    t.index ["permalink"], name: "index_app_documents_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_app_documents_on_published_at_and_expires_at"
    t.index ["slug_id"], name: "index_app_documents_on_slug_id"
    t.index ["status_id"], name: "index_app_documents_on_status_id"
    t.check_constraint "status_id >= 0", name: "app_documents_status_id_non_negative"
  end

  create_table "com_document_categories", force: :cascade do |t|
    t.bigint "com_document_category_master_id", default: 0, null: false
    t.bigint "com_document_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["com_document_category_master_id"], name: "idx_on_com_document_category_master_id_dc650e897c"
    t.index ["com_document_id"], name: "index_com_document_categories_on_com_document_id", unique: true
    t.check_constraint "com_document_category_master_id >= 0", name: "com_document_categories_com_document_category_master_id_non_neg"
  end

  create_table "com_document_category_masters", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.index ["parent_id"], name: "index_com_document_category_masters_on_parent_id"
  end

  create_table "com_document_revisions", force: :cascade do |t|
    t.text "body"
    t.bigint "com_document_id", null: false
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
    t.index ["com_document_id", "created_at"], name: "index_com_document_revisions_on_com_document_id_and_created_at"
    t.index ["edited_by_id"], name: "index_com_document_revisions_on_edited_by_id"
    t.index ["public_id"], name: "index_com_document_revisions_on_public_id", unique: true
  end

  create_table "com_document_statuses", force: :cascade do |t|
  end

  create_table "com_document_tag_masters", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.index ["parent_id"], name: "index_com_document_tag_masters_on_parent_id"
  end

  create_table "com_document_tags", force: :cascade do |t|
    t.bigint "com_document_id", null: false
    t.bigint "com_document_tag_master_id", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["com_document_id"], name: "index_com_document_tags_on_com_document_id"
    t.index ["com_document_tag_master_id", "com_document_id"], name: "idx_com_document_tags_on_master_and_document", unique: true
    t.check_constraint "com_document_tag_master_id >= 0", name: "com_document_tags_com_document_tag_master_id_non_negative"
  end

  create_table "com_document_versions", force: :cascade do |t|
    t.text "body"
    t.bigint "com_document_id", null: false
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
    t.index ["com_document_id", "created_at"], name: "index_com_document_versions_on_com_document_id_and_created_at"
    t.index ["edited_by_id"], name: "index_com_document_versions_on_edited_by_id"
    t.index ["public_id"], name: "index_com_document_versions_on_public_id", unique: true
  end

  create_table "com_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.bigint "latest_revision_id"
    t.bigint "latest_version_id"
    t.integer "lock_version", default: 0, null: false
    t.string "permalink", limit: 200, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", default: "", null: false
    t.string "slug_id", limit: 32, default: "", null: false
    t.bigint "status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["latest_revision_id"], name: "index_com_documents_on_latest_revision_id", unique: true
    t.index ["latest_version_id"], name: "index_com_documents_on_latest_version_id", unique: true
    t.index ["permalink"], name: "index_com_documents_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_com_documents_on_published_at_and_expires_at"
    t.index ["slug_id"], name: "index_com_documents_on_slug_id"
    t.index ["status_id"], name: "index_com_documents_on_status_id"
    t.check_constraint "status_id >= 0", name: "com_documents_status_id_non_negative"
  end

  create_table "org_document_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "org_document_category_master_id", default: 0, null: false
    t.bigint "org_document_id", null: false
    t.datetime "updated_at", null: false
    t.index ["org_document_category_master_id"], name: "idx_on_org_document_category_master_id_0d3d809e93"
    t.index ["org_document_id"], name: "index_org_document_categories_on_org_document_id", unique: true
    t.check_constraint "org_document_category_master_id >= 0", name: "org_document_categories_org_document_category_master_id_non_neg"
  end

  create_table "org_document_category_masters", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.index ["parent_id"], name: "index_org_document_category_masters_on_parent_id"
  end

  create_table "org_document_revisions", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.bigint "org_document_id", null: false
    t.string "permalink", limit: 200, null: false
    t.string "public_id", limit: 255, default: "", null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["edited_by_id"], name: "index_org_document_revisions_on_edited_by_id"
    t.index ["org_document_id", "created_at"], name: "index_org_document_revisions_on_org_document_id_and_created_at"
    t.index ["public_id"], name: "index_org_document_revisions_on_public_id", unique: true
  end

  create_table "org_document_statuses", force: :cascade do |t|
  end

  create_table "org_document_tag_masters", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.index ["parent_id"], name: "index_org_document_tag_masters_on_parent_id"
  end

  create_table "org_document_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "org_document_id", null: false
    t.bigint "org_document_tag_master_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["org_document_id"], name: "index_org_document_tags_on_org_document_id"
    t.index ["org_document_tag_master_id", "org_document_id"], name: "idx_org_document_tags_on_master_and_document", unique: true
    t.check_constraint "org_document_tag_master_id >= 0", name: "org_document_tags_org_document_tag_master_id_non_negative"
  end

  create_table "org_document_versions", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.bigint "org_document_id", null: false
    t.string "permalink", limit: 200, null: false
    t.string "public_id", limit: 255, default: "", null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["edited_by_id"], name: "index_org_document_versions_on_edited_by_id"
    t.index ["org_document_id", "created_at"], name: "index_org_document_versions_on_org_document_id_and_created_at"
    t.index ["public_id"], name: "index_org_document_versions_on_public_id", unique: true
  end

  create_table "org_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.bigint "latest_revision_id"
    t.bigint "latest_version_id"
    t.integer "lock_version", default: 0, null: false
    t.string "permalink", limit: 200, default: "", null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", default: "", null: false
    t.string "slug_id", limit: 32, default: "", null: false
    t.bigint "status_id", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["latest_revision_id"], name: "index_org_documents_on_latest_revision_id", unique: true
    t.index ["latest_version_id"], name: "index_org_documents_on_latest_version_id", unique: true
    t.index ["permalink"], name: "index_org_documents_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_org_documents_on_published_at_and_expires_at"
    t.index ["slug_id"], name: "index_org_documents_on_slug_id"
    t.index ["status_id"], name: "index_org_documents_on_status_id"
    t.check_constraint "status_id >= 0", name: "org_documents_status_id_non_negative"
  end

  add_foreign_key "app_document_categories", "app_document_category_masters"
  add_foreign_key "app_document_categories", "app_documents", on_delete: :cascade, validate: false
  add_foreign_key "app_document_category_masters", "app_document_category_masters", column: "parent_id"
  add_foreign_key "app_document_revisions", "app_documents", on_delete: :cascade
  add_foreign_key "app_document_tag_masters", "app_document_tag_masters", column: "parent_id"
  add_foreign_key "app_document_tags", "app_document_tag_masters"
  add_foreign_key "app_document_tags", "app_documents", on_delete: :cascade, validate: false
  add_foreign_key "app_document_versions", "app_documents", on_delete: :cascade, validate: false
  add_foreign_key "app_documents", "app_document_revisions", column: "latest_revision_id", on_delete: :nullify, validate: false
  add_foreign_key "app_documents", "app_document_statuses", column: "status_id"
  add_foreign_key "app_documents", "app_document_versions", column: "latest_version_id", on_delete: :nullify, validate: false
  add_foreign_key "com_document_categories", "com_document_category_masters"
  add_foreign_key "com_document_categories", "com_documents", on_delete: :cascade, validate: false
  add_foreign_key "com_document_category_masters", "com_document_category_masters", column: "parent_id"
  add_foreign_key "com_document_revisions", "com_documents", on_delete: :cascade
  add_foreign_key "com_document_tag_masters", "com_document_tag_masters", column: "parent_id"
  add_foreign_key "com_document_tags", "com_document_tag_masters"
  add_foreign_key "com_document_tags", "com_documents", on_delete: :cascade, validate: false
  add_foreign_key "com_document_versions", "com_documents", on_delete: :cascade, validate: false
  add_foreign_key "com_documents", "com_document_revisions", column: "latest_revision_id", on_delete: :nullify, validate: false
  add_foreign_key "com_documents", "com_document_statuses", column: "status_id"
  add_foreign_key "com_documents", "com_document_versions", column: "latest_version_id", on_delete: :nullify, validate: false
  add_foreign_key "org_document_categories", "org_document_category_masters"
  add_foreign_key "org_document_categories", "org_documents", on_delete: :cascade, validate: false
  add_foreign_key "org_document_category_masters", "org_document_category_masters", column: "parent_id"
  add_foreign_key "org_document_revisions", "org_documents", on_delete: :cascade
  add_foreign_key "org_document_tag_masters", "org_document_tag_masters", column: "parent_id"
  add_foreign_key "org_document_tags", "org_document_tag_masters"
  add_foreign_key "org_document_tags", "org_documents", on_delete: :cascade, validate: false
  add_foreign_key "org_document_versions", "org_documents", on_delete: :cascade, validate: false
  add_foreign_key "org_documents", "org_document_revisions", column: "latest_revision_id", on_delete: :nullify, validate: false
  add_foreign_key "org_documents", "org_document_statuses", column: "status_id"
  add_foreign_key "org_documents", "org_document_versions", column: "latest_version_id", on_delete: :nullify, validate: false
end
