# frozen_string_literal: true

class MigrateOrgContactStatusesToSmallint < ActiveRecord::Migration[8.2]
  def up
    return unless column_exists?(:org_contacts, :status_id)

    safety_assured do
      # 1. Add id_small to reference table
      add_column(:org_contact_statuses, :id_small, :integer, limit: 2)

      # 2. Safety check
      count = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM org_contact_statuses")
      raise RuntimeError, "Too many records in org_contact_statuses" if count > 32_767

      # 3. Backfill id_small
      has_neyo = ActiveRecord::Base.connection.select_value("SELECT 1 FROM org_contact_statuses WHERE id = 'NEYO'")

      if has_neyo
        execute("UPDATE org_contact_statuses SET id_small = 0 WHERE id = 'NEYO'")
        execute(<<~SQL.squish)
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn
            FROM org_contact_statuses
            WHERE id != 'NEYO'
          )
          UPDATE org_contact_statuses
          SET id_small = numbered.rn
          FROM numbered
          WHERE org_contact_statuses.id = numbered.id
        SQL
      else
        execute(<<~SQL.squish)
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn
            FROM org_contact_statuses
          )
          UPDATE org_contact_statuses
          SET id_small = numbered.rn
          FROM numbered
          WHERE org_contact_statuses.id = numbered.id
        SQL
      end

      # 3.5 Unique constraint for FK
      add_index(:org_contact_statuses, :id_small, unique: true)

      # 4. Add status_id_small to child table
      add_column(:org_contacts, :status_id_small, :integer, limit: 2)

      # 5. Backfill child table
      execute(<<~SQL.squish)
        UPDATE org_contacts
        SET status_id_small = org_contact_statuses.id_small
        FROM org_contact_statuses
        WHERE org_contacts.status_id = org_contact_statuses.id
      SQL

      # 6. Remove old FK and Add new FK
      remove_foreign_key(:org_contacts, :org_contact_statuses)
      add_foreign_key(:org_contacts, :org_contact_statuses, column: :status_id_small, primary_key: :id_small)

      # 7. Drop old columns
      remove_column(:org_contacts, :status_id)
      remove_column(:org_contact_statuses, :id)

      # 8. Rename columns

      rename_column(:org_contact_statuses, :id_small, :id)

      rename_column(:org_contacts, :status_id_small, :status_id)

      # 9. Set Primary Key
      execute("ALTER TABLE org_contact_statuses ADD PRIMARY KEY (id)")

      # 10. Set NOT NULL and Default
      change_column_null(:org_contact_statuses, :id, false)

      # We set default to 0 (NEYO's value or just 0)
      change_column_default(:org_contacts, :status_id, 0)
      change_column_null(:org_contacts, :status_id, false)

      # 11. Indexes
      add_index(:org_contacts, :status_id)

      # 12. Check Constraints
      add_check_constraint(:org_contact_statuses, "id >= 0", name: "chk_org_contact_statuses_id_positive")
      add_check_constraint(:org_contacts, "status_id >= 0", name: "chk_org_contacts_status_id_positive")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
