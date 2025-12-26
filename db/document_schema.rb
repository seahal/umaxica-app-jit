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

ActiveRecord::Schema[8.2].define(version: 2025_12_26_000005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "app_document_versions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.uuid "app_document_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.string "permalink", limit: 200, null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["app_document_id", "created_at"], name: "index_app_document_versions_on_app_document_id_and_created_at"
    t.index ["app_document_id"], name: "index_app_document_versions_on_app_document_id"
  end

  create_table "app_documents", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.string "permalink", limit: 200, null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_app_documents_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_app_documents_on_published_at_and_expires_at"
  end

  create_table "com_document_versions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "body"
    t.uuid "com_document_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.string "permalink", limit: 200, null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["com_document_id", "created_at"], name: "index_com_document_versions_on_com_document_id_and_created_at"
    t.index ["com_document_id"], name: "index_com_document_versions_on_com_document_id"
  end

  create_table "com_documents", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.string "permalink", limit: 200, null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_com_documents_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_com_documents_on_published_at_and_expires_at"
  end

  create_table "org_document_versions", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "edited_by_id"
    t.string "edited_by_type"
    t.datetime "expires_at", null: false
    t.uuid "org_document_id", null: false
    t.string "permalink", limit: 200, null: false
    t.datetime "published_at", null: false
    t.string "redirect_url"
    t.string "response_mode", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["org_document_id", "created_at"], name: "index_org_document_versions_on_org_document_id_and_created_at"
    t.index ["org_document_id"], name: "index_org_document_versions_on_org_document_id"
  end

  create_table "org_documents", id: :uuid, default: -> { "uuidv7()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", default: ::Float::INFINITY, null: false
    t.string "permalink", limit: 200, null: false
    t.integer "position", default: 0, null: false
    t.datetime "published_at", default: ::Float::INFINITY, null: false
    t.string "redirect_url"
    t.string "response_mode", default: "html", null: false
    t.string "revision_key", null: false
    t.datetime "updated_at", null: false
    t.index ["permalink"], name: "index_org_documents_on_permalink", unique: true
    t.index ["published_at", "expires_at"], name: "index_org_documents_on_published_at_and_expires_at"
  end

  add_foreign_key "app_document_versions", "app_documents"
  add_foreign_key "com_document_versions", "com_documents"
  add_foreign_key "org_document_versions", "org_documents"
end
