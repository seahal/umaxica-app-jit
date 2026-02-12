# frozen_string_literal: true

class AddIdFormatConstraintsToActivityAuditTables < ActiveRecord::Migration[8.2]
  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id::text ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables_to_constrain
    %w(
      user_audit_levels
      user_audit_events
      staff_audit_levels
      staff_audit_events
      org_timeline_audit_levels
      org_timeline_audit_events
      com_timeline_audit_levels
      com_timeline_audit_events
      app_timeline_audit_levels
      app_timeline_audit_events
      org_document_audit_levels
      org_document_audit_events
      com_document_audit_levels
      com_document_audit_events
      app_document_audit_levels
      app_document_audit_events
    )
  end
end
