# frozen_string_literal: true

class SeedGuestStatuses < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Cleanup diagnostic data
      execute "DELETE FROM app_contact_statuses WHERE id = 'TEST_SQL' OR id = 'TEST_STATUS'"

      # AppContactStatus
      app_statuses = [
        { id: 'APP_SITE_STATUS', description: 'ROOT', parent_title: '' },
        { id: 'SET_UP', description: 'first step completed', parent_title: '' },
        { id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_title: '' },
        { id: 'CHECKED_TELEPHONE_NUMBER', description: 'third step completed', parent_title: '' },
        { id: 'COMPLETED_CONTACT_ACTION', description: 'contact completed', parent_title: '' },
        { id: 'NEYO', description: 'null status', parent_title: '' },
      ]
      upsert_table('app_contact_statuses', app_statuses)

      # ComContactStatus
      com_statuses = [
        { id: "NEYO", description: "root of service site status inquiries", parent_id: nil, position: 0, active: true },
        { id: "SET_UP", description: "first step completed", parent_id: "NEYO", position: 0, active: true },
        { id: "CHECKED_EMAIL_ADDRESS", description: "second step completed", parent_id: "SET_UP", position: 0, active: true },
        { id: "CHECKED_TELEPHONE_NUMBER", description: "second step completed", parent_id: "CHECKED_EMAIL_ADDRESS", position: 0, active: true },
        { id: "COMPLETED_CONTACT_ACTION", description: "second step completed", parent_id: "CHECKED_TELEPHONE_NUMBER", position: 0, active: true },
        { id: "NULL_COM_STATUS", description: "null status for com contact", parent_id: nil, position: 0, active: true },
      ]
      upsert_table('com_contact_statuses', com_statuses)

      # OrgContactStatus
      org_statuses = [
        { id: 'ORGANIZATION_SITE_STATUS', description: 'ROOT', parent_id: nil },
        { id: 'SET_UP', description: 'first step completed', parent_id: 'ORGANIZATION_SITE_STATUS' },
        { id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_id: 'SET_UP' },
        { id: 'CHECKED_TELEPHONE_NUMBER', description: 'third step completed', parent_id: 'CHECKED_EMAIL_ADDRESS' },
        { id: 'COMPLETED_CONTACT_ACTION', description: 'contact completed', parent_id: 'CHECKED_TELEPHONE_NUMBER' },
        { id: 'NEYO', description: 'null status', parent_id: nil },
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
    rows.each do |row|
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
