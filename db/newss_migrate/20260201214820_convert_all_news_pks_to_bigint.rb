# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class ConvertAllNewsPksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension "citext" unless extension_enabled?("citext")

    # Drop all news tables with int/serial/string PKs
    drop_table :app_timeline_statuses, if_exists: true, force: :cascade
    drop_table :com_timeline_statuses, if_exists: true, force: :cascade
    drop_table :org_timeline_statuses, if_exists: true, force: :cascade
    drop_table :app_timeline_category_masters, if_exists: true, force: :cascade
    drop_table :com_timeline_category_masters, if_exists: true, force: :cascade
    drop_table :org_timeline_category_masters, if_exists: true, force: :cascade
    drop_table :app_timeline_tag_masters, if_exists: true, force: :cascade
    drop_table :com_timeline_tag_masters, if_exists: true, force: :cascade
    drop_table :org_timeline_tag_masters, if_exists: true, force: :cascade

    # Recreate all tables with bigint PK + code column
    create_table :app_timeline_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :com_timeline_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :org_timeline_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :app_timeline_category_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :com_timeline_category_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :org_timeline_category_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :app_timeline_tag_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :com_timeline_tag_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :org_timeline_tag_masters, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
# rubocop:enable Rails/BulkChangeTable
