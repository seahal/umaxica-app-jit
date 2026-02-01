# frozen_string_literal: true

class MigrateComContactStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Add id_small to reference table
      add_column :com_contact_statuses, :id_small, :integer, limit: 2

      # 2. Safety check
      count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM com_contact_statuses")
      raise "Too many records in com_contact_statuses" if count > 32_767

      # 3. Backfill id_small
      has_neyo = ActiveRecord::Base.connection.select_value("SELECT 1 FROM com_contact_statuses WHERE id = 'NEYO'")

      if has_neyo
        execute("UPDATE com_contact_statuses SET id_small = 0 WHERE id = 'NEYO'")
        execute <<~SQL.squish
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn
            FROM com_contact_statuses
            WHERE id != 'NEYO'
          )
          UPDATE com_contact_statuses
          SET id_small = numbered.rn
          FROM numbered
          WHERE com_contact_statuses.id = numbered.id
        SQL
      else
        execute <<~SQL.squish
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn
            FROM com_contact_statuses
          )
          UPDATE com_contact_statuses
          SET id_small = numbered.rn
          FROM numbered
          WHERE com_contact_statuses.id = numbered.id
        SQL
      end

      # 3.5 Unique constraint for FK
      add_index :com_contact_statuses, :id_small, unique: true

      # 4. Add status_id_small to child table
      add_column :com_contacts, :status_id_small, :integer, limit: 2

      # 5. Backfill child table
      execute <<~SQL.squish
        UPDATE com_contacts
        SET status_id_small = com_contact_statuses.id_small
        FROM com_contact_statuses
        WHERE com_contacts.status_id = com_contact_statuses.id
      SQL

      # 6. Remove old FK and Add new FK
      remove_foreign_key :com_contacts, :com_contact_statuses
      add_foreign_key :com_contacts, :com_contact_statuses, column: :status_id_small, primary_key: :id_small

      # 7. Drop old columns
      remove_column :com_contacts, :status_id
      remove_column :com_contact_statuses, :id

      # 8. Rename columns
      # rubocop:disable Rails/DangerousColumnNames
      rename_column :com_contact_statuses, :id_small, :id
      # rubocop:enable Rails/DangerousColumnNames
      rename_column :com_contacts, :status_id_small, :status_id

      # 9. Set Primary Key
      execute "ALTER TABLE com_contact_statuses ADD PRIMARY KEY (id)"

      # 10. Set NOT NULL and Default
      change_column_null :com_contact_statuses, :id, false
      change_column_default :com_contacts, :status_id, 0
      change_column_null :com_contacts, :status_id, false

      # 11. Indexes
      add_index :com_contacts, :status_id

      # 12. Check Constraints
      add_check_constraint :com_contact_statuses, "id >= 0", name: "chk_com_contact_statuses_id_positive"
      add_check_constraint :com_contacts, "status_id >= 0", name: "chk_com_contacts_status_id_positive"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
