# frozen_string_literal: true

class MigrateAppContactStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Add id_small to reference table
      add_column :app_contact_statuses, :id_small, :integer, limit: 2

      # 2. Safety check
      count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM app_contact_statuses")
      raise "Too many records in app_contact_statuses" if count > 32_767

      # 3. Backfill id_small
      has_neyo = ActiveRecord::Base.connection.select_value("SELECT 1 FROM app_contact_statuses WHERE id = 'NEYO'")

      if has_neyo
        execute("UPDATE app_contact_statuses SET id_small = 0 WHERE id = 'NEYO'")
        execute <<~SQL.squish
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn
            FROM app_contact_statuses
            WHERE id != 'NEYO'
          )
          UPDATE app_contact_statuses
          SET id_small = numbered.rn
          FROM numbered
          WHERE app_contact_statuses.id = numbered.id
        SQL
      else
        execute <<~SQL.squish
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn
            FROM app_contact_statuses
          )
          UPDATE app_contact_statuses
          SET id_small = numbered.rn
          FROM numbered
          WHERE app_contact_statuses.id = numbered.id
        SQL
      end

      # 3.5 Unique constraint for FK
      add_index :app_contact_statuses, :id_small, unique: true

      # 4. Add status_id_small to child table
      add_column :app_contacts, :status_id_small, :integer, limit: 2

      # 5. Backfill child table
      execute <<~SQL.squish
        UPDATE app_contacts
        SET status_id_small = app_contact_statuses.id_small
        FROM app_contact_statuses
        WHERE app_contacts.status_id = app_contact_statuses.id
      SQL

      # 6. Remove old FK and Add new FK
      remove_foreign_key :app_contacts, :app_contact_statuses
      add_foreign_key :app_contacts, :app_contact_statuses, column: :status_id_small, primary_key: :id_small

      # 7. Drop old columns
      remove_column :app_contacts, :status_id
      remove_column :app_contact_statuses, :id

      # 8. Rename columns
      # rubocop:disable Rails/DangerousColumnNames
      rename_column :app_contact_statuses, :id_small, :id
      # rubocop:enable Rails/DangerousColumnNames
      rename_column :app_contacts, :status_id_small, :status_id

      # 9. Set Primary Key
      execute "ALTER TABLE app_contact_statuses ADD PRIMARY KEY (id)"

      # 10. Set NOT NULL and Default
      change_column_null :app_contact_statuses, :id, false
      change_column_default :app_contacts, :status_id, 0
      change_column_null :app_contacts, :status_id, false

      # 11. Indexes
      add_index :app_contacts, :status_id

      # 12. Check Constraints
      add_check_constraint :app_contact_statuses, "id >= 0", name: "chk_app_contact_statuses_id_positive"
      add_check_constraint :app_contacts, "status_id >= 0", name: "chk_app_contacts_status_id_positive"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
