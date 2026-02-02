# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class ConvertAllDocumentPksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension "citext" unless extension_enabled?("citext")

    # Drop all document tables with int/serial/string PKs
    drop_table :app_document_statuses, if_exists: true, force: :cascade
    drop_table :com_document_statuses, if_exists: true, force: :cascade
    drop_table :org_document_statuses, if_exists: true, force: :cascade
    drop_table :app_document_category_masters, if_exists: true, force: :cascade
    drop_table :com_document_category_masters, if_exists: true, force: :cascade
    drop_table :org_document_category_masters, if_exists: true, force: :cascade
    drop_table :app_document_tag_masters, if_exists: true, force: :cascade
    drop_table :com_document_tag_masters, if_exists: true, force: :cascade
    drop_table :org_document_tag_masters, if_exists: true, force: :cascade

    # Recreate all tables with bigint PK + code column
    create_table :app_document_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_document_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_document_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_document_category_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_document_category_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_document_category_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_document_tag_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_document_tag_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_document_tag_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
# rubocop:enable Rails/BulkChangeTable
