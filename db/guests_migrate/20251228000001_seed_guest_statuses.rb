# frozen_string_literal: true

class SeedGuestStatuses < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Cleanup diagnostic data
      execute "DELETE FROM app_contact_statuses WHERE id = 'TEST_SQL' OR id = 'TEST_STATUS'"

      # AppContactStatus
      app_statuses = [
        { id: 'NEYO', description: 'NEYO', parent_title: '', position: 1, active: true },
        { id: 'SET_UP', description: 'Set Up', parent_title: '', position: 2, active: true },
        { id: 'CHECKED_EMAIL_ADDRESS', description: 'Checked Email', parent_title: '', position: 3, active: true },
        { id: 'CHECKED_TELEPHONE_NUMBER', description: 'Checked Telephone', parent_title: '', position: 4, active: true },
        { id: 'COMPLETED', description: 'Completed', parent_title: '', position: 5, active: true },
        { id: 'COMPLETED_CONTACT_ACTION', description: 'Completed Contact Action', parent_title: '', position: 6, active: true },
      ]
      upsert_table('app_contact_statuses', app_statuses)

      # ComContactStatus
      com_statuses = [
        { id: "NEYO", description: "NEYO", parent_id: nil, position: 1, active: true },
        { id: "SET_UP", description: "Set Up", parent_id: nil, position: 2, active: true },
        { id: "CHECKED_EMAIL_ADDRESS", description: "Checked Email", parent_id: nil, position: 3, active: true },
        { id: "CHECKED_TELEPHONE_NUMBER", description: "Checked Telephone", parent_id: nil, position: 4, active: true },
        { id: "COMPLETED", description: "Completed", parent_id: nil, position: 5, active: true },
        { id: "COMPLETED_CONTACT_ACTION", description: "Completed Contact Action", parent_id: nil, position: 6, active: true },
      ]
      upsert_table('com_contact_statuses', com_statuses)

      # OrgContactStatus
      org_statuses = [
        { id: 'NEYO', description: 'NEYO', parent_id: nil, position: 1, active: true },
        { id: 'SET_UP', description: 'Set Up', parent_id: nil, position: 2, active: true },
        { id: 'CHECKED_EMAIL_ADDRESS', description: 'Checked Email', parent_id: nil, position: 3, active: true },
        { id: 'CHECKED_TELEPHONE_NUMBER', description: 'Checked Telephone', parent_id: nil, position: 4, active: true },
        { id: 'COMPLETED', description: 'Completed', parent_id: nil, position: 5, active: true },
        { id: 'COMPLETED_CONTACT_ACTION', description: 'Completed Contact Action', parent_id: nil, position: 6, active: true },
      ]
      upsert_table('org_contact_statuses', org_statuses)
    end
  end

  def down
    safety_assured do
      execute "DELETE FROM app_contact_statuses"
      execute "DELETE FROM com_contact_statuses"
      execute "DELETE FROM org_contact_statuses"
    end
  end

  private

  def upsert_table(table_name, rows)
    now = Time.current
    has_created_at = connection.column_exists?(table_name, :created_at)
    has_updated_at = connection.column_exists?(table_name, :updated_at)

    rows.each do |row|
      row[:created_at] ||= now if has_created_at
      row[:updated_at] ||= now if has_updated_at

      cols = row.keys.join(", ")
      vals = row.values.map { |v| connection.quote(v) }.join(", ")

      updates = row.keys.map do |k|
        "#{k} = EXCLUDED.#{k}"
      end.join(", ")

      sql = <<~SQL.squish
        INSERT INTO #{table_name} (#{cols})#{" "}
        VALUES (#{vals})#{" "}
        ON CONFLICT (id) DO UPDATE SET #{updates}
      SQL

      execute sql
    end
  end
end
