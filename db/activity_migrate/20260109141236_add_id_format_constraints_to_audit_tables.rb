# frozen_string_literal: true

class AddIdFormatConstraintsToAuditTables < ActiveRecord::Migration[8.2]
  # Audit tables with string IDs that should only allow uppercase alphanumeric + underscore

  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id ~ '^[A-Z0-9_]+$')
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
    [
      # Org Preference Audit
      "org_preference_audit_levels",
      "org_preference_audit_events",

      # Com Preference Audit
      "com_preference_audit_levels",
      "com_preference_audit_events",

      # App Preference Audit
      "app_preference_audit_levels",
      "app_preference_audit_events",
    ]
  end
end
