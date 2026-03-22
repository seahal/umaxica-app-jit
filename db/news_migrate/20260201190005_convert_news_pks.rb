# frozen_string_literal: true

class ConvertNewsPks < ActiveRecord::Migration[8.0]
  def up
    # -------------------------------------------------------------------------
    # APP TIMELINES
    # -------------------------------------------------------------------------
    drop_table(:app_timeline_revisions, if_exists: true)
    drop_table(:app_timeline_versions, if_exists: true)
    drop_table(:app_timeline_categories, if_exists: true)
    drop_table(:app_timeline_tags, if_exists: true)
    drop_table(:app_timelines, if_exists: true)

    create_table(:app_timelines) do |t|
      t.datetime("created_at", null: false)
      t.datetime("expires_at", default: Float::INFINITY, null: false)
      t.integer("lock_version", default: 0, null: false)
      t.integer("position", default: 0, null: false)
      t.datetime("published_at", default: Float::INFINITY, null: false)
      t.string("redirect_url")
      t.string("response_mode", default: "html", null: false)
      t.string("slug_id", limit: 32, default: "", null: false)
      t.integer("status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["published_at", "expires_at"], name: "index_app_timelines_on_published_at_and_expires_at")
      t.index(["slug_id"], name: "index_app_timelines_on_slug_id")
      t.index(["status_id"], name: "index_app_timelines_on_status_id")
      t.check_constraint("status_id >= 0", name: "app_timelines_status_id_non_negative")
    end

    create_table(:app_timeline_revisions) do |t|
      t.bigint("app_timeline_id", null: false)
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

      t.index(["app_timeline_id", "created_at"], name: "index_app_timeline_revisions_on_app_timeline_id_and_created_at")
      t.index(["app_timeline_id"], name: "index_app_timeline_revisions_on_app_timeline_id")
      t.index(["public_id"], name: "index_app_timeline_revisions_on_public_id", unique: true)
    end

    create_table(:app_timeline_versions) do |t|
      t.bigint("app_timeline_id", null: false)
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

      t.index(["app_timeline_id", "created_at"], name: "index_app_timeline_versions_on_app_timeline_id_and_created_at")
      t.index(["public_id"], name: "index_app_timeline_versions_on_public_id", unique: true)
    end

    create_table(:app_timeline_categories) do |t|
      t.integer("app_timeline_category_master_id", limit: 2, default: 0, null: false)
      t.bigint("app_timeline_id", null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["app_timeline_category_master_id"], name: "idx_on_app_timeline_category_master_id_d1179f51ba")
      t.index(["app_timeline_id"], name: "index_app_timeline_categories_unique", unique: true)
      t.check_constraint(
        "app_timeline_category_master_id >= 0",
        name: "app_timeline_categories_app_timeline_category_master_id_non_neg",
      )
    end

    create_table(:app_timeline_tags) do |t|
      t.bigint("app_timeline_id", null: false)
      t.integer("app_timeline_tag_master_id", limit: 2, default: 0, null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["app_timeline_tag_master_id"], name: "index_app_timeline_tags_on_app_timeline_tag_master_id")
      t.check_constraint(
        "app_timeline_tag_master_id >= 0",
        name: "app_timeline_tags_app_timeline_tag_master_id_non_negative",
      )
    end

    add_foreign_key("app_timelines", "app_timeline_statuses", column: "status_id", validate: false)
    add_foreign_key("app_timeline_revisions", "app_timelines", validate: false)
    add_foreign_key("app_timeline_versions", "app_timelines", on_delete: :cascade, validate: false)
    add_foreign_key("app_timeline_categories", "app_timeline_category_masters", validate: false)
    add_foreign_key("app_timeline_categories", "app_timelines", on_delete: :cascade, validate: false)
    add_foreign_key("app_timeline_tags", "app_timeline_tag_masters", validate: false)
    add_foreign_key("app_timeline_tags", "app_timelines", on_delete: :cascade, validate: false)

    # -------------------------------------------------------------------------
    # COM TIMELINES
    # -------------------------------------------------------------------------
    drop_table(:com_timeline_revisions, if_exists: true)
    drop_table(:com_timeline_versions, if_exists: true)
    drop_table(:com_timeline_categories, if_exists: true)
    drop_table(:com_timeline_tags, if_exists: true)
    drop_table(:com_timelines, if_exists: true)

    create_table(:com_timelines) do |t|
      t.datetime("created_at", null: false)
      t.datetime("expires_at", default: Float::INFINITY, null: false)
      t.integer("lock_version", default: 0, null: false)
      t.integer("position", default: 0, null: false)
      t.datetime("published_at", default: Float::INFINITY, null: false)
      t.string("redirect_url")
      t.string("response_mode", default: "html", null: false)
      t.string("slug_id", limit: 32, default: "", null: false)
      t.integer("status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["published_at", "expires_at"], name: "index_com_timelines_on_published_at_and_expires_at")
      t.index(["slug_id"], name: "index_com_timelines_on_slug_id")
      t.index(["status_id"], name: "index_com_timelines_on_status_id")
      t.check_constraint("status_id >= 0", name: "com_timelines_status_id_non_negative")
    end

    create_table(:com_timeline_revisions) do |t|
      t.text("body")
      t.bigint("com_timeline_id", null: false)
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

      t.index(["com_timeline_id", "created_at"], name: "index_com_timeline_revisions_on_com_timeline_id_and_created_at")
      t.index(["com_timeline_id"], name: "index_com_timeline_revisions_on_com_timeline_id")
      t.index(["public_id"], name: "index_com_timeline_revisions_on_public_id", unique: true)
    end

    create_table(:com_timeline_versions) do |t|
      t.text("body")
      t.bigint("com_timeline_id", null: false)
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

      t.index(["com_timeline_id", "created_at"], name: "index_com_timeline_versions_on_com_timeline_id_and_created_at")
      t.index(["public_id"], name: "index_com_timeline_versions_on_public_id", unique: true)
    end

    create_table(:com_timeline_categories) do |t|
      t.integer("com_timeline_category_master_id", limit: 2, default: 0, null: false)
      t.bigint("com_timeline_id", null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["com_timeline_category_master_id"], name: "idx_on_com_timeline_category_master_id_3ab8427d3a")
      t.index(["com_timeline_id"], name: "index_com_timeline_categories_unique", unique: true)
      t.check_constraint(
        "com_timeline_category_master_id >= 0",
        name: "com_timeline_categories_com_timeline_category_master_id_non_neg",
      )
    end

    create_table(:com_timeline_tags) do |t|
      t.bigint("com_timeline_id", null: false)
      t.integer("com_timeline_tag_master_id", limit: 2, default: 0, null: false)
      t.datetime("created_at", null: false)
      t.datetime("updated_at", null: false)

      t.index(["com_timeline_tag_master_id"], name: "index_com_timeline_tags_on_com_timeline_tag_master_id")
      t.check_constraint(
        "com_timeline_tag_master_id >= 0",
        name: "com_timeline_tags_com_timeline_tag_master_id_non_negative",
      )
    end

    add_foreign_key("com_timelines", "com_timeline_statuses", column: "status_id", validate: false)
    add_foreign_key("com_timeline_revisions", "com_timelines", validate: false)
    add_foreign_key("com_timeline_versions", "com_timelines", on_delete: :cascade, validate: false)
    add_foreign_key("com_timeline_categories", "com_timeline_category_masters", validate: false)
    add_foreign_key("com_timeline_categories", "com_timelines", on_delete: :cascade, validate: false)
    add_foreign_key("com_timeline_tags", "com_timeline_tag_masters", validate: false)
    add_foreign_key("com_timeline_tags", "com_timelines", on_delete: :cascade, validate: false)

    # -------------------------------------------------------------------------
    # ORG TIMELINES
    # -------------------------------------------------------------------------
    drop_table(:org_timeline_revisions, if_exists: true)
    drop_table(:org_timeline_versions, if_exists: true)
    drop_table(:org_timeline_categories, if_exists: true)
    drop_table(:org_timeline_tags, if_exists: true)
    drop_table(:org_timelines, if_exists: true)

    create_table(:org_timelines) do |t|
      t.datetime("created_at", null: false)
      t.datetime("expires_at", default: Float::INFINITY, null: false)
      t.integer("lock_version", default: 0, null: false)
      t.integer("position", default: 0, null: false)
      t.datetime("published_at", default: Float::INFINITY, null: false)
      t.string("redirect_url")
      t.string("response_mode", default: "html", null: false)
      t.string("slug_id", limit: 32, default: "", null: false)
      t.integer("status_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["published_at", "expires_at"], name: "index_org_timelines_on_published_at_and_expires_at")
      t.index(["slug_id"], name: "index_org_timelines_on_slug_id")
      t.index(["status_id"], name: "index_org_timelines_on_status_id")
      t.check_constraint("status_id >= 0", name: "org_timelines_status_id_non_negative")
    end

    create_table(:org_timeline_revisions) do |t|
      t.text("body")
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.bigint("org_timeline_id", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["org_timeline_id", "created_at"], name: "index_org_timeline_revisions_on_org_timeline_id_and_created_at")
      t.index(["org_timeline_id"], name: "index_org_timeline_revisions_on_org_timeline_id")
      t.index(["public_id"], name: "index_org_timeline_revisions_on_public_id", unique: true)
    end

    create_table(:org_timeline_versions) do |t|
      t.text("body")
      t.datetime("created_at", null: false)
      t.string("description")
      t.bigint("edited_by_id")
      t.string("edited_by_type")
      t.datetime("expires_at", null: false)
      t.bigint("org_timeline_id", null: false)
      t.string("permalink", limit: 200, null: false)
      t.string("public_id", limit: 255, default: "", null: false)
      t.datetime("published_at", null: false)
      t.string("redirect_url")
      t.string("response_mode", null: false)
      t.string("title")
      t.datetime("updated_at", null: false)

      t.index(["org_timeline_id", "created_at"], name: "index_org_timeline_versions_on_org_timeline_id_and_created_at")
      t.index(["public_id"], name: "index_org_timeline_versions_on_public_id", unique: true)
    end

    create_table(:org_timeline_categories) do |t|
      t.datetime("created_at", null: false)
      t.integer("org_timeline_category_master_id", limit: 2, default: 0, null: false)
      t.bigint("org_timeline_id", null: false)
      t.datetime("updated_at", null: false)

      t.index(["org_timeline_category_master_id"], name: "idx_on_org_timeline_category_master_id_fa21cb5b0c")
      t.index(["org_timeline_id"], name: "index_org_timeline_categories_unique", unique: true)
      t.check_constraint(
        "org_timeline_category_master_id >= 0",
        name: "org_timeline_categories_org_timeline_category_master_id_non_neg",
      )
    end

    create_table(:org_timeline_tags) do |t|
      t.datetime("created_at", null: false)
      t.bigint("org_timeline_id", null: false)
      t.integer("org_timeline_tag_master_id", limit: 2, default: 0, null: false)
      t.datetime("updated_at", null: false)

      t.index(["org_timeline_tag_master_id"], name: "index_org_timeline_tags_on_org_timeline_tag_master_id")
      t.check_constraint(
        "org_timeline_tag_master_id >= 0",
        name: "org_timeline_tags_org_timeline_tag_master_id_non_negative",
      )
    end

    add_foreign_key("org_timelines", "org_timeline_statuses", column: "status_id", validate: false)
    add_foreign_key("org_timeline_revisions", "org_timelines", validate: false)
    add_foreign_key("org_timeline_versions", "org_timelines", on_delete: :cascade, validate: false)
    add_foreign_key("org_timeline_categories", "org_timeline_category_masters", validate: false)
    add_foreign_key("org_timeline_categories", "org_timelines", on_delete: :cascade, validate: false)
    add_foreign_key("org_timeline_tags", "org_timeline_tag_masters", validate: false)
    add_foreign_key("org_timeline_tags", "org_timelines", on_delete: :cascade, validate: false)

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
