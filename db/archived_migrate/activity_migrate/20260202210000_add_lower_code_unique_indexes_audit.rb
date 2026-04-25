# frozen_string_literal: true

class AddLowerCodeUniqueIndexesAudit < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %w(
    app_document_audit_events
    app_document_audit_levels
    app_preference_audit_events
    app_preference_audit_levels
    app_timeline_audit_events
    app_timeline_audit_levels
    com_document_audit_events
    com_document_audit_levels
    com_preference_audit_events
    com_preference_audit_levels
    com_timeline_audit_events
    com_timeline_audit_levels
    org_document_audit_events
    org_document_audit_levels
    org_preference_audit_events
    org_preference_audit_levels
    org_timeline_audit_events
    org_timeline_audit_levels
    staff_audit_events
    staff_audit_levels
    user_audit_events
    user_audit_levels
  ).freeze

  def up
    safety_assured do
      TABLES.each do |table|
        add_lower_code_index(table)
      end
    end
  end

  def down
    TABLES.each do |table|
      index_name = "index_#{table}_on_lower_code"
      remove_index(table, name: index_name) if index_exists?(table, nil, name: index_name)
    end
  end

  private

  def add_lower_code_index(table)
    return unless table_exists?(table) && column_exists?(table, :code)

    index_name = "index_#{table}_on_lower_code"
    return if index_exists?(table, nil, name: index_name)

    add_index(table, "lower(code)", unique: true, name: index_name, algorithm: :concurrently)
  end
end
