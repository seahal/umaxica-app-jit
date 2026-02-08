# frozen_string_literal: true

# rubocop:disable Rails/BulkChangeTable
class ConvertAllAuditPksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension "citext" unless extension_enabled?("citext")

    # Drop all audit tables with int/serial/string PKs
    drop_table :app_document_audit_events, if_exists: true, force: :cascade
    drop_table :com_document_audit_events, if_exists: true, force: :cascade
    drop_table :org_document_audit_events, if_exists: true, force: :cascade
    drop_table :app_document_audit_levels, if_exists: true, force: :cascade
    drop_table :com_document_audit_levels, if_exists: true, force: :cascade
    drop_table :org_document_audit_levels, if_exists: true, force: :cascade
    drop_table :app_preference_audit_events, if_exists: true, force: :cascade
    drop_table :com_preference_audit_events, if_exists: true, force: :cascade
    drop_table :org_preference_audit_events, if_exists: true, force: :cascade
    drop_table :app_preference_audit_levels, if_exists: true, force: :cascade
    drop_table :com_preference_audit_levels, if_exists: true, force: :cascade
    drop_table :org_preference_audit_levels, if_exists: true, force: :cascade
    drop_table :app_timeline_audit_events, if_exists: true, force: :cascade
    drop_table :com_timeline_audit_events, if_exists: true, force: :cascade
    drop_table :org_timeline_audit_events, if_exists: true, force: :cascade
    drop_table :app_timeline_audit_levels, if_exists: true, force: :cascade
    drop_table :com_timeline_audit_levels, if_exists: true, force: :cascade
    drop_table :org_timeline_audit_levels, if_exists: true, force: :cascade
    drop_table :staff_audit_events, if_exists: true, force: :cascade
    drop_table :staff_audit_levels, if_exists: true, force: :cascade
    drop_table :user_audit_events, if_exists: true, force: :cascade
    drop_table :user_audit_levels, if_exists: true, force: :cascade

    # Recreate all tables with bigint PK + code column
    create_table :app_document_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_document_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_document_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_document_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_document_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_document_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_preference_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_preference_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_preference_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_preference_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_preference_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_preference_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_timeline_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_timeline_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_timeline_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :app_timeline_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :com_timeline_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :org_timeline_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :staff_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :staff_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :user_audit_events, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end

    create_table :user_audit_levels, id: :bigint do |t|
      t.citext :code, null: false, index: { unique: true }
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
# rubocop:enable Rails/BulkChangeTable
