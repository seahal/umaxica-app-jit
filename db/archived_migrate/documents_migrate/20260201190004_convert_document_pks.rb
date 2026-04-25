# frozen_string_literal: true

class ConvertDocumentPks < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
    # -------------------------------------------------------------------------
    # APP DOCUMENTS
    # -------------------------------------------------------------------------
    safety_assured do
      execute("DROP TABLE IF EXISTS app_document_revisions CASCADE")
      execute("DROP TABLE IF EXISTS app_document_versions CASCADE")
      execute("DROP TABLE IF EXISTS app_document_categories CASCADE")
      execute("DROP TABLE IF EXISTS app_document_tags CASCADE")
      execute("DROP TABLE IF EXISTS app_documents CASCADE")
    end

    create_table(:app_documents) do |t|
      t.datetime("created_at", null: false)
      t.datetime("expires_at", default: Float::INFINITY, null: false)
      t.integer("lock_version", default: 0, null: false)
      t.string("permalink", limit: 200, default: "", null: false)
      t.integer("position", default: 0, null: false)
      t.datetime("published_at", default: Float::INFINITY, null: false)
      t.string("redirect_url")
      t.string("response_mode", default: "html", null: false)
      t.string("revision_key", default: "", null: false)
      t.string("slug_id", limit: 32, default: "", null: false)
      t.integer("status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["permalink"], name: "index_app_documents_on_permalink", unique: true)
      t.index(["published_at", "expires_at"], name: "index_app_documents_on_published_at_and_expires_at")
      t.index(["slug_id"], name: "index_app_documents_on_slug_id")
      t.index(["status_id"], name: "index_app_documents_on_status_id")
      t.check_constraint("status_id >= 0", name: "app_documents_status_id_non_negative")
    end

    create_table(:app_document_revisions) do |t|
      t.bigint("app_document_id", null: false)
      t.text("body")
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["app_document_id", "created_at"], name: "index_app_document_revisions_on_app_document_id_and_created_at")
      t.index(["app_document_id"], name: "index_app_document_revisions_on_app_document_id")
      t.index(["public_id"], name: "index_app_document_revisions_on_public_id", unique: true)
    end

    create_table(:app_document_versions) do |t|
      t.bigint("app_document_id", null: false)
      t.text("body")
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["app_document_id", "created_at"], name: "index_app_document_versions_on_app_document_id_and_created_at")
      t.index(["public_id"], name: "index_app_document_versions_on_public_id", unique: true)
    end

    create_table(:app_document_categories) do |t|
      t.integer("app_document_category_master_id", limit: 2, default: 0, null: false)
      t.bigint("app_document_id", null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["app_document_category_master_id"], name: "idx_on_app_document_category_master_id_018a74a5ab")
      t.index(["app_document_id"], name: "index_app_document_categories_on_app_document_id", unique: true)
      t.check_constraint(
        "app_document_category_master_id >= 0",
        name: "app_document_categories_app_document_category_master_id_non_neg",
      )
    end

    create_table(:app_document_tags) do |t|
      t.bigint("app_document_id", null: false)
      t.integer("app_document_tag_master_id", limit: 2, default: 0, null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["app_document_tag_master_id"], name: "index_app_document_tags_on_app_document_tag_master_id")
      t.check_constraint(
        "app_document_tag_master_id >= 0",
        name: "app_document_tags_app_document_tag_master_id_non_negative",
      )
    end

    add_foreign_key("app_documents", "app_document_statuses", column: "status_id", validate: false)
    add_foreign_key("app_document_revisions", "app_documents", validate: false)
    add_foreign_key("app_document_versions", "app_documents", on_delete: :cascade, validate: false)
    add_foreign_key("app_document_categories", "app_document_category_masters", validate: false)
    add_foreign_key("app_document_categories", "app_documents", on_delete: :cascade, validate: false)
    add_foreign_key("app_document_tags", "app_document_tag_masters", validate: false)
    add_foreign_key("app_document_tags", "app_documents", on_delete: :cascade, validate: false)

    # -------------------------------------------------------------------------
    # COM DOCUMENTS
    # -------------------------------------------------------------------------
    safety_assured do
      execute("DROP TABLE IF EXISTS com_document_revisions CASCADE")
      execute("DROP TABLE IF EXISTS com_document_versions CASCADE")
      execute("DROP TABLE IF EXISTS com_document_categories CASCADE")
      execute("DROP TABLE IF EXISTS com_document_tags CASCADE")
      execute("DROP TABLE IF EXISTS com_documents CASCADE")
    end

    create_table(:com_documents) do |t|
      t.datetime("created_at", null: false)
      t.datetime("expires_at", default: Float::INFINITY, null: false)
      t.integer("lock_version", default: 0, null: false)
      t.string("permalink", limit: 200, default: "", null: false)
      t.integer("position", default: 0, null: false)
      t.datetime("published_at", default: Float::INFINITY, null: false)
      t.string("redirect_url")
      t.string("response_mode", default: "html", null: false)
      t.string("revision_key", default: "", null: false)
      t.string("slug_id", limit: 32, default: "", null: false)
      t.integer("status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["permalink"], name: "index_com_documents_on_permalink", unique: true)
      t.index(["published_at", "expires_at"], name: "index_com_documents_on_published_at_and_expires_at")
      t.index(["slug_id"], name: "index_com_documents_on_slug_id")
      t.index(["status_id"], name: "index_com_documents_on_status_id")
      t.check_constraint("status_id >= 0", name: "com_documents_status_id_non_negative")
    end

    create_table(:com_document_revisions) do |t|
      t.text("body")
      t.bigint("com_document_id", null: false)
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["com_document_id", "created_at"], name: "index_com_document_revisions_on_com_document_id_and_created_at")
      t.index(["com_document_id"], name: "index_com_document_revisions_on_com_document_id")
      t.index(["public_id"], name: "index_com_document_revisions_on_public_id", unique: true)
    end

    create_table(:com_document_versions) do |t|
      t.text("body")
      t.bigint("com_document_id", null: false)
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["com_document_id", "created_at"], name: "index_com_document_versions_on_com_document_id_and_created_at")
      t.index(["public_id"], name: "index_com_document_versions_on_public_id", unique: true)
    end

    create_table(:com_document_categories) do |t|
      t.integer("com_document_category_master_id", limit: 2, default: 0, null: false)
      t.bigint("com_document_id", null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["com_document_category_master_id"], name: "idx_on_com_document_category_master_id_dc650e897c")
      t.index(["com_document_id"], name: "index_com_document_categories_on_com_document_id", unique: true)
      t.check_constraint(
        "com_document_category_master_id >= 0",
        name: "com_document_categories_com_document_category_master_id_non_neg",
      )
    end

    create_table(:com_document_tags) do |t|
      t.bigint("com_document_id", null: false)
      t.integer("com_document_tag_master_id", limit: 2, default: 0, null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["com_document_tag_master_id"], name: "index_com_document_tags_on_com_document_tag_master_id")
      t.check_constraint(
        "com_document_tag_master_id >= 0",
        name: "com_document_tags_com_document_tag_master_id_non_negative",
      )
    end

    add_foreign_key("com_documents", "com_document_statuses", column: "status_id", validate: false)
    add_foreign_key("com_document_revisions", "com_documents", validate: false)
    add_foreign_key("com_document_versions", "com_documents", on_delete: :cascade, validate: false)
    add_foreign_key("com_document_categories", "com_document_category_masters", validate: false)
    add_foreign_key("com_document_categories", "com_documents", on_delete: :cascade, validate: false)
    add_foreign_key("com_document_tags", "com_document_tag_masters", validate: false)
    add_foreign_key("com_document_tags", "com_documents", on_delete: :cascade, validate: false)

    # -------------------------------------------------------------------------
    # ORG DOCUMENTS
    # -------------------------------------------------------------------------
    safety_assured do
      execute("DROP TABLE IF EXISTS org_document_revisions CASCADE")
      execute("DROP TABLE IF EXISTS org_document_versions CASCADE")
      execute("DROP TABLE IF EXISTS org_document_categories CASCADE")
      execute("DROP TABLE IF EXISTS org_document_tags CASCADE")
      execute("DROP TABLE IF EXISTS org_documents CASCADE")
    end

    create_table(:org_documents) do |t|
      t.datetime("created_at", null: false)
      t.datetime("expires_at", default: Float::INFINITY, null: false)
      t.integer("lock_version", default: 0, null: false)
      t.string("permalink", limit: 200, default: "", null: false)
      t.integer("position", default: 0, null: false)
      t.datetime("published_at", default: Float::INFINITY, null: false)
      t.string("redirect_url")
      t.string("response_mode", default: "html", null: false)
      t.string("revision_key", default: "", null: false)
      t.string("slug_id", limit: 32, default: "", null: false)
      t.integer("status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["permalink"], name: "index_org_documents_on_permalink", unique: true)
      t.index(["published_at", "expires_at"], name: "index_org_documents_on_published_at_and_expires_at")
      t.index(["slug_id"], name: "index_org_documents_on_slug_id")
      t.index(["status_id"], name: "index_org_documents_on_status_id")
      t.check_constraint("status_id >= 0", name: "org_documents_status_id_non_negative")
    end

    create_table(:org_document_revisions) do |t|
      t.text("body")
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.bigint("org_document_id", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["org_document_id", "created_at"], name: "index_org_document_revisions_on_org_document_id_and_created_at")
      t.index(["org_document_id"], name: "index_org_document_revisions_on_org_document_id")
      t.index(["public_id"], name: "index_org_document_revisions_on_public_id", unique: true)
    end

    create_table(:org_document_versions) do |t|
      t.text("body")
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.bigint("org_document_id", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["org_document_id", "created_at"], name: "index_org_document_versions_on_org_document_id_and_created_at")
      t.index(["public_id"], name: "index_org_document_versions_on_public_id", unique: true)
    end

    create_table(:org_document_categories) do |t|
      t.datetime("created_at", null: false)
      t.integer("org_document_category_master_id", limit: 2, default: 0, null: false)
      t.bigint("org_document_id", null: false)
      t.datetime("updated_at", null: false)

      t.index(["org_document_category_master_id"], name: "idx_on_org_document_category_master_id_0d3d809e93")
      t.index(["org_document_id"], name: "index_org_document_categories_on_org_document_id", unique: true)
      t.check_constraint(
        "org_document_category_master_id >= 0",
        name: "org_document_categories_org_document_category_master_id_non_neg",
      )
    end

    create_table(:org_document_tags) do |t|
      t.datetime("created_at", null: false)
      t.bigint("org_document_id", null: false)
      t.integer("org_document_tag_master_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["org_document_tag_master_id"], name: "index_org_document_tags_on_org_document_tag_master_id")
      t.check_constraint(
        "org_document_tag_master_id >= 0",
        name: "org_document_tags_org_document_tag_master_id_non_negative",
      )
    end

    add_foreign_key("org_documents", "org_document_statuses", column: "status_id", validate: false)
    add_foreign_key("org_document_revisions", "org_documents", validate: false)
    add_foreign_key("org_document_versions", "org_documents", on_delete: :cascade, validate: false)
    add_foreign_key("org_document_categories", "org_document_category_masters", validate: false)
    add_foreign_key("org_document_categories", "org_documents", on_delete: :cascade, validate: false)
    add_foreign_key("org_document_tags", "org_document_tag_masters", validate: false)
    add_foreign_key("org_document_tags", "org_documents", on_delete: :cascade, validate: false)

  end

    end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
