# frozen_string_literal: true

class FinalizeAuditReferenceSmallint < ActiveRecord::Migration[8.2]
  REFERENCE_TABLES = %w(
    app_contact_audit_events
    app_document_audit_events
    app_preference_audit_events
    app_timeline_audit_events
    com_contact_audit_events
    com_document_audit_events
    com_preference_audit_events
    com_timeline_audit_events
    org_contact_audit_events
    org_document_audit_events
    org_preference_audit_events
    org_timeline_audit_events
    staff_audit_events
    user_audit_events

    app_contact_audit_levels
    app_document_audit_levels
    app_preference_audit_levels
    app_timeline_audit_levels
    com_contact_audit_levels
    com_document_audit_levels
    com_preference_audit_levels
    com_timeline_audit_levels
    org_contact_audit_levels
    org_document_audit_levels
    org_preference_audit_levels
    org_timeline_audit_levels
    staff_audit_levels
    user_audit_levels
  ).freeze

  CHILD_COLUMNS = {
    app_contact_histories: {
      event_id: :app_contact_audit_events,
      level_id: :app_contact_audit_levels,
    },
    app_document_audits: {
      event_id: :app_document_audit_events,
      level_id: :app_document_audit_levels,
    },
    app_preference_audits: {
      event_id: :app_preference_audit_events,
      level_id: :app_preference_audit_levels,
    },
    app_timeline_audits: {
      event_id: :app_timeline_audit_events,
      level_id: :app_timeline_audit_levels,
    },
    com_contact_audits: {
      event_id: :com_contact_audit_events,
      level_id: :com_contact_audit_levels,
    },
    com_document_audits: {
      event_id: :com_document_audit_events,
      level_id: :com_document_audit_levels,
    },
    com_preference_audits: {
      event_id: :com_preference_audit_events,
      level_id: :com_preference_audit_levels,
    },
    com_timeline_audits: {
      event_id: :com_timeline_audit_events,
      level_id: :com_timeline_audit_levels,
    },
    org_contact_histories: {
      event_id: :org_contact_audit_events,
      level_id: :org_contact_audit_levels,
    },
    org_document_audits: {
      event_id: :org_document_audit_events,
      level_id: :org_document_audit_levels,
    },
    org_preference_audits: {
      event_id: :org_preference_audit_events,
      level_id: :org_preference_audit_levels,
    },
    org_timeline_audits: {
      event_id: :org_timeline_audit_events,
      level_id: :org_timeline_audit_levels,
    },
    staff_audits: {
      event_id: :staff_audit_events,
      level_id: :staff_audit_levels,
    },
    user_audits: {
      event_id: :user_audit_events,
      level_id: :user_audit_levels,
    },
  }.freeze

  def up
    safety_assured do
      drop_preference_id_format_checks

      REFERENCE_TABLES.each do |table_name|
        drop_primary_key_constraint(table_name)
        remove_column table_name, :id if column_exists?(table_name, :id)
        rename_column table_name, :id_small, :id
        change_column_default table_name, :id, from: 0, to: 0
        change_column_null table_name, :id, false
        add_check_constraint table_name, "id >= 0", name: "#{table_name}_id_non_negative"
        add_primary_key_constraint(table_name)
      end

      add_child_foreign_keys
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def drop_preference_id_format_checks
    %w(
      app_preference_audit_events
      app_preference_audit_levels
      org_preference_audit_events
      org_preference_audit_levels
      com_preference_audit_events
      com_preference_audit_levels
    ).each do |table_name|
      execute <<~SQL.squish
        ALTER TABLE #{table_name}
        DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
      SQL
    end
  end

  def drop_primary_key_constraint(table_name)
    execute <<~SQL.squish
      ALTER TABLE #{table_name}
      DROP CONSTRAINT IF EXISTS #{table_name}_pkey
    SQL
  end

  def add_primary_key_constraint(table_name)
    execute <<~SQL.squish
      ALTER TABLE #{table_name}
      ADD PRIMARY KEY (id)
    SQL
  end

  def add_child_foreign_keys
    CHILD_COLUMNS.each do |table_name, columns|
      columns.each do |column_name, parent_table|
        add_foreign_key table_name, parent_table, column: column_name, primary_key: :id
      end
    end
  end
end
