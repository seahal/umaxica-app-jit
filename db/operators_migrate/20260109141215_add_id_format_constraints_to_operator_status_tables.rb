# frozen_string_literal: true

class AddIdFormatConstraintsToOperatorStatusTables < ActiveRecord::Migration[8.2]
  def up
    tables.each do |table_name|
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
    tables.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

    def tables
      %w[
        organization_statuses
        division_statuses
        workspace_statuses
        admin_statuses
        staff_telephone_statuses
        staff_statuses
        staff_secret_statuses
        staff_passkey_statuses
        staff_email_statuses
      ]
    end
end
