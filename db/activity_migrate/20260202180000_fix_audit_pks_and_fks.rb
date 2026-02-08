# frozen_string_literal: true

class FixAuditPksAndFks < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Applications
      fix_audit_domain(:app_contact)
      fix_audit_domain(:app_document)
      fix_audit_domain(:app_preference)
      fix_audit_domain(:app_timeline)

      # Companies (Com)
      fix_audit_domain(:com_contact)
      fix_audit_domain(:com_document)
      fix_audit_domain(:com_preference)
      fix_audit_domain(:com_timeline)

      # Organizations (Org)
      fix_audit_domain(:org_contact)
      fix_audit_domain(:org_document)
      fix_audit_domain(:org_preference)
      fix_audit_domain(:org_timeline)

      # Staff
      fix_audit_domain(:staff)

      # User
      fix_audit_domain(:user)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fix_audit_domain(prefix)
    events_table = "#{prefix}_audit_events"
    levels_table = "#{prefix}_audit_levels"

    audit_table =
      if table_exists?("#{prefix}_audits")
        "#{prefix}_audits"
      elsif table_exists?("#{prefix}_histories")
        "#{prefix}_histories"
      else
        nil
      end

    return unless audit_table

    execute "TRUNCATE TABLE #{audit_table} CASCADE" if table_exists?(audit_table)

    recreate_pk_table(events_table)
    recreate_pk_table(levels_table)

    [:event_id, :level_id].each do |col|
      if column_exists?(audit_table, col)
        # Use execute for altering type
        execute "ALTER TABLE #{audit_table} ALTER COLUMN #{col} TYPE bigint USING #{col}::bigint"
        execute "ALTER TABLE #{audit_table} ALTER COLUMN #{col} SET DEFAULT 0"
        execute "ALTER TABLE #{audit_table} ALTER COLUMN #{col} SET NOT NULL"

        to_table = (col == :event_id) ? events_table : levels_table
        unless foreign_key_exists?(audit_table, to_table)
          add_foreign_key audit_table, to_table, column: col, validate: false
        end
      end
    end
  end

  def recreate_pk_table(table_name)
    return unless table_exists?(table_name)

    drop_table table_name, force: :cascade
    create_table table_name do |t|
      t.citext :code, null: false
      t.index :code, unique: true
    end
  end
end
