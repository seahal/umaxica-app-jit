# frozen_string_literal: true

class AuditReferenceTableTimestampsRemoval < ActiveRecord::Migration[8.2]
  TARGET_TABLES = %i(
    app_contact_audit_events
    app_contact_audit_levels
    app_document_audit_events
    app_document_audit_levels
    app_preference_audit_events
    app_preference_audit_levels
    app_timeline_audit_events
    app_timeline_audit_levels
    com_contact_audit_events
    com_contact_audit_levels
    com_document_audit_events
    com_document_audit_levels
    com_preference_audit_events
    com_preference_audit_levels
    com_timeline_audit_events
    com_timeline_audit_levels
    org_contact_audit_events
    org_contact_audit_levels
    org_document_audit_events
    org_document_audit_levels
    org_preference_audit_events
    org_preference_audit_levels
    org_timeline_audit_events
    org_timeline_audit_levels
    user_audit_events
    user_audit_levels
  ).freeze

  def up
    TARGET_TABLES.each do |table|
      next unless table_exists?(table)

      safety_assured do
        remove_column(table, :created_at) if column_exists?(table, :created_at)
        remove_column(table, :updated_at) if column_exists?(table, :updated_at)
      end
    end
  end

  def down
    TARGET_TABLES.each do |table|
      next unless table_exists?(table)

      safety_assured do
        add_column(
          table,
          :created_at,
          :datetime,
          null: false,
          default: -> { "CURRENT_TIMESTAMP" },
        ) unless column_exists?(table, :created_at)
        add_column(
          table,
          :updated_at,
          :datetime,
          null: false,
          default: -> { "CURRENT_TIMESTAMP" },
        ) unless column_exists?(table, :updated_at)

        change_column_default(table, :created_at, nil) if column_exists?(table, :created_at)
        change_column_default(table, :updated_at, nil) if column_exists?(table, :updated_at)
      end
    end
  end
end
