# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class ConvertAllGuestPksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension "citext" unless extension_enabled?("citext")

    # Drop all guest tables with int/serial/string PKs
    drop_table :app_contact_statuses, if_exists: true, force: :cascade
    drop_table :com_contact_statuses, if_exists: true, force: :cascade
    drop_table :org_contact_statuses, if_exists: true, force: :cascade
    drop_table :app_contact_categories, if_exists: true, force: :cascade
    drop_table :com_contact_categories, if_exists: true, force: :cascade
    drop_table :org_contact_categories, if_exists: true, force: :cascade
    drop_table :app_contact_emails, if_exists: true, force: :cascade
    drop_table :com_contact_emails, if_exists: true, force: :cascade
    drop_table :org_contact_emails, if_exists: true, force: :cascade
    drop_table :app_contact_telephones, if_exists: true, force: :cascade
    drop_table :com_contact_telephones, if_exists: true, force: :cascade
    drop_table :org_contact_telephones, if_exists: true, force: :cascade

    # Recreate all tables with bigint PK + code column
    create_table :app_contact_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_contact_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_contact_statuses, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_contact_categories, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_contact_categories, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_contact_categories, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_contact_emails, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_contact_emails, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_contact_emails, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_contact_telephones, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_contact_telephones, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_contact_telephones, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
# rubocop:enable Rails/BulkChangeTable
