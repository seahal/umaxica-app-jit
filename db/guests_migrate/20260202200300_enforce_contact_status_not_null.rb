# frozen_string_literal: true

class EnforceContactStatusNotNull < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      # 1. OrgContact
      ensure_status_not_null(:org_contacts, :org_contact_statuses, "status_id")

      # 2. ComContact
      ensure_status_not_null(:com_contacts, :com_contact_statuses, "status_id")

      # 3. AppContact
      ensure_status_not_null(:app_contacts, :app_contact_statuses, "status_id")
    end
  end

  def down
    safety_assured do
      change_column_null(:org_contacts, :status_id, true)
      change_column_null(:com_contacts, :status_id, true)
      change_column_null(:app_contacts, :status_id, true)
    end
  end

  private

  def ensure_status_not_null(table_name, status_table, column_name)
    return unless table_exists?(table_name) && table_exists?(status_table)

    # Ensure a default row exists in the status table
    # Using code 'NEYO' (common in this app) or 'default'
    execute(<<~SQL.squish)
      INSERT INTO #{status_table} (code)
      VALUES ('NEYO')
      ON CONFLICT (code) DO NOTHING
    SQL

    default_id = connection.select_value(<<~SQL.squish)
      SELECT id FROM #{status_table} WHERE code = 'NEYO'
    SQL

    return unless default_id

    # Update NULLs to default_id
    execute(<<~SQL.squish)
      UPDATE #{table_name} SET #{column_name} = #{default_id} WHERE #{column_name} IS NULL
    SQL

    # Set NOT NULL
    change_column_null(table_name, column_name, false)

    # Ensure index exists
    index_name = "index_#{table_name}_on_#{column_name}"
    return if index_exists?(table_name, column_name, name: index_name)

    add_index(table_name, column_name, name: index_name, algorithm: :concurrently)

  end
end
