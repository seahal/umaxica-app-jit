# frozen_string_literal: true

class CreateDocumentTablesInPublication < ActiveRecord::Migration[8.2]
  PREFIXES = %w(app com org).freeze

  def up
    PREFIXES.each do |prefix|
      ensure_status_table(prefix)
      ensure_master_table("#{prefix}_document_tag_masters")
      ensure_master_table("#{prefix}_document_category_masters")
      ensure_documents_table(prefix)
      ensure_versions_table(prefix)
      ensure_revisions_table(prefix)
      ensure_tags_table(prefix)
      ensure_categories_table(prefix)
      ensure_document_foreign_keys(prefix)
      seed_statuses(prefix)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "document tables now belong to publication"
  end

  private

  def ensure_status_table(prefix)
    create_table("#{prefix}_document_statuses", if_not_exists: true, id: false) do |t|
      t.bigint(:id, null: false, primary_key: true)
    end
  end

  def ensure_master_table(table_name)
    create_table(table_name, if_not_exists: true) do |t|
      t.bigint(:parent_id, null: false)
    end

    add_index(table_name, :parent_id, if_not_exists: true)
  end

  def ensure_documents_table(prefix)
    table_name = "#{prefix}_documents"

    create_table(table_name, if_not_exists: true) do |t|
      t.datetime(:created_at, null: false)
      t.datetime(:expires_at, null: false, default: -> { "'infinity'" })
      t.bigint(:latest_revision_id)
      t.bigint(:latest_version_id)
      t.integer(:lock_version, null: false, default: 0)
      t.string(:permalink, limit: 200, null: false, default: "")
      t.integer(:position, null: false, default: 0)
      t.datetime(:published_at, null: false, default: -> { "'infinity'" })
      t.string(:redirect_url)
      t.string(:response_mode, null: false, default: "html")
      t.string(:revision_key, null: false, default: "")
      t.string(:slug_id, limit: 32, null: false, default: "")
      t.bigint(:status_id, null: false, default: 0)
      t.datetime(:updated_at, null: false)
    end

    add_column(table_name, :latest_revision_id, :bigint) unless column_exists?(table_name, :latest_revision_id)
    add_column(table_name, :latest_version_id, :bigint) unless column_exists?(table_name, :latest_version_id)
    add_column(table_name, :lock_version, :integer, null: false, default: 0) unless column_exists?(table_name, :lock_version)
    add_column(table_name, :permalink, :string, limit: 200, null: false, default: "") unless column_exists?(table_name, :permalink)
    add_column(table_name, :position, :integer, null: false, default: 0) unless column_exists?(table_name, :position)
    add_column(table_name, :response_mode, :string, null: false, default: "html") unless column_exists?(table_name, :response_mode)
    add_column(table_name, :revision_key, :string, null: false, default: "") unless column_exists?(table_name, :revision_key)
    add_column(table_name, :slug_id, :string, limit: 32, null: false, default: "") unless column_exists?(table_name, :slug_id)
    add_column(table_name, :status_id, :bigint, null: false, default: 0) unless column_exists?(table_name, :status_id)
    add_column(table_name, :redirect_url, :string) unless column_exists?(table_name, :redirect_url)

    add_index(table_name, :latest_revision_id, unique: true, if_not_exists: true)
    add_index(table_name, :latest_version_id, unique: true, if_not_exists: true)
    add_index(table_name, :permalink, unique: true, if_not_exists: true)
    add_index(table_name, %i(published_at expires_at), if_not_exists: true)
    add_index(table_name, :slug_id, if_not_exists: true)
    add_index(table_name, :status_id, if_not_exists: true)
  end

  def ensure_versions_table(prefix)
    table_name = "#{prefix}_document_versions"
    foreign_key_column = "#{prefix}_document_id"

    create_table(table_name, if_not_exists: true) do |t|
      t.bigint(foreign_key_column, null: false)
      t.text(:body)
      t.datetime(:created_at, null: false)
      t.string(:description)
      t.bigint(:edited_by_id)
      t.string(:edited_by_type)
      t.datetime(:expires_at, null: false)
      t.string(:permalink, limit: 200, null: false)
      t.string(:public_id, limit: 255, null: false, default: "")
      t.datetime(:published_at, null: false)
      t.string(:redirect_url)
      t.string(:response_mode, null: false)
      t.string(:title)
      t.datetime(:updated_at, null: false)
    end

    add_column(table_name, foreign_key_column, :bigint, null: false, default: 0) unless column_exists?(table_name, foreign_key_column)
    add_column(table_name, :public_id, :string, limit: 255, null: false, default: "") unless column_exists?(table_name, :public_id)
    add_index(table_name, [foreign_key_column, :created_at], if_not_exists: true)
    add_index(table_name, :edited_by_id, if_not_exists: true)
    add_index(table_name, :public_id, unique: true, if_not_exists: true)
  end

  def ensure_revisions_table(prefix)
    table_name = "#{prefix}_document_revisions"
    foreign_key_column = "#{prefix}_document_id"

    create_table(table_name, if_not_exists: true) do |t|
      t.bigint(foreign_key_column, null: false)
      t.text(:body)
      t.datetime(:created_at, null: false)
      t.string(:description)
      t.bigint(:edited_by_id)
      t.string(:edited_by_type)
      t.datetime(:expires_at, null: false)
      t.string(:permalink, limit: 200, null: false)
      t.string(:public_id, limit: 255, null: false, default: "")
      t.datetime(:published_at, null: false)
      t.string(:redirect_url)
      t.string(:response_mode, null: false)
      t.string(:title)
      t.datetime(:updated_at, null: false)
    end

    add_column(table_name, foreign_key_column, :bigint, null: false, default: 0) unless column_exists?(table_name, foreign_key_column)
    add_column(table_name, :public_id, :string, limit: 255, null: false, default: "") unless column_exists?(table_name, :public_id)
    add_index(table_name, [foreign_key_column, :created_at], if_not_exists: true)
    add_index(table_name, :edited_by_id, if_not_exists: true)
    add_index(table_name, :public_id, unique: true, if_not_exists: true)
  end

  def ensure_tags_table(prefix)
    table_name = "#{prefix}_document_tags"
    document_foreign_key = "#{prefix}_document_id"
    master_foreign_key = "#{prefix}_document_tag_master_id"

    create_table(table_name, if_not_exists: true) do |t|
      t.bigint(document_foreign_key, null: false)
      t.bigint(master_foreign_key, null: false, default: 0)
      t.datetime(:created_at, null: false)
      t.datetime(:updated_at, null: false)
    end

    add_column(table_name, document_foreign_key, :bigint, null: false, default: 0) unless column_exists?(table_name, document_foreign_key)
    add_column(table_name, master_foreign_key, :bigint, null: false, default: 0) unless column_exists?(table_name, master_foreign_key)
    add_index(table_name, document_foreign_key, if_not_exists: true)
    add_index(table_name, [master_foreign_key, document_foreign_key], unique: true, if_not_exists: true)
  end

  def ensure_categories_table(prefix)
    table_name = "#{prefix}_document_categories"
    document_foreign_key = "#{prefix}_document_id"
    master_foreign_key = "#{prefix}_document_category_master_id"

    create_table(table_name, if_not_exists: true) do |t|
      t.bigint(master_foreign_key, null: false, default: 0)
      t.bigint(document_foreign_key, null: false)
      t.datetime(:created_at, null: false)
      t.datetime(:updated_at, null: false)
    end

    add_column(table_name, document_foreign_key, :bigint, null: false, default: 0) unless column_exists?(table_name, document_foreign_key)
    add_column(table_name, master_foreign_key, :bigint, null: false, default: 0) unless column_exists?(table_name, master_foreign_key)
    add_index(table_name, master_foreign_key, if_not_exists: true)
    add_index(table_name, document_foreign_key, unique: true, if_not_exists: true)
  end

  def ensure_document_foreign_keys(prefix)
    documents_table = "#{prefix}_documents"
    versions_table = "#{prefix}_document_versions"
    revisions_table = "#{prefix}_document_revisions"
    statuses_table = "#{prefix}_document_statuses"
    tag_masters_table = "#{prefix}_document_tag_masters"
    tags_table = "#{prefix}_document_tags"
    category_masters_table = "#{prefix}_document_category_masters"
    categories_table = "#{prefix}_document_categories"

    add_foreign_key(versions_table, documents_table, column: "#{prefix}_document_id", validate: false) unless foreign_key_exists?(versions_table, documents_table, column: "#{prefix}_document_id")
    add_foreign_key(revisions_table, documents_table, column: "#{prefix}_document_id", validate: false) unless foreign_key_exists?(revisions_table, documents_table, column: "#{prefix}_document_id")
    add_foreign_key(documents_table, statuses_table, column: :status_id, validate: false) unless foreign_key_exists?(documents_table, statuses_table, column: :status_id)
    add_foreign_key(documents_table, versions_table, column: :latest_version_id, validate: false) unless foreign_key_exists?(documents_table, versions_table, column: :latest_version_id)
    add_foreign_key(documents_table, revisions_table, column: :latest_revision_id, validate: false) unless foreign_key_exists?(documents_table, revisions_table, column: :latest_revision_id)
    add_foreign_key(tag_masters_table, tag_masters_table, column: :parent_id, validate: false) unless foreign_key_exists?(tag_masters_table, tag_masters_table, column: :parent_id)
    add_foreign_key(tags_table, tag_masters_table, column: "#{prefix}_document_tag_master_id", validate: false) unless foreign_key_exists?(tags_table, tag_masters_table, column: "#{prefix}_document_tag_master_id")
    add_foreign_key(tags_table, documents_table, column: "#{prefix}_document_id", validate: false) unless foreign_key_exists?(tags_table, documents_table, column: "#{prefix}_document_id")
    add_foreign_key(category_masters_table, category_masters_table, column: :parent_id, validate: false) unless foreign_key_exists?(category_masters_table, category_masters_table, column: :parent_id)
    add_foreign_key(categories_table, category_masters_table, column: "#{prefix}_document_category_master_id", validate: false) unless foreign_key_exists?(categories_table, category_masters_table, column: "#{prefix}_document_category_master_id")
    add_foreign_key(categories_table, documents_table, column: "#{prefix}_document_id", validate: false) unless foreign_key_exists?(categories_table, documents_table, column: "#{prefix}_document_id")
  end

  def seed_statuses(prefix)
    table_name = "#{prefix}_document_statuses"
    ids =
      case prefix
      when "com"
        [0, 1, 2, 3, 4, 5, 6, 7]
      else
        [1, 2, 3, 4, 5, 6, 7]
      end

    safety_assured do
      existing_ids = select_values("SELECT id FROM #{table_name} WHERE id IN (#{ids.join(",")})").map(&:to_i)
      (ids - existing_ids).each do |id|
        execute("INSERT INTO #{table_name} (id) VALUES (#{id})")
      end
    end
  end
end
