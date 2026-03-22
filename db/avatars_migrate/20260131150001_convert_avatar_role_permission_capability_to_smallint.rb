# frozen_string_literal: true

class ConvertAvatarRolePermissionCapabilityToSmallint < ActiveRecord::Migration[8.2]
  TABLES = %w(
    avatar_capabilities
    avatar_permissions
    avatar_roles
    post_review_statuses
  ).freeze

  def up
    TABLES.each do |table|
      safety_assured do
        # 1. Add new column
        add_column(table, :id_small, :integer, limit: 2)

        # 2. Backfill: ORDER BY key for stable numbering (key is unique)
        # Starting from 1, 0 reserved for NEYO/none/unknown if needed
        execute(<<~SQL.squish)
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY key) AS rn
            FROM #{table}
          )
          UPDATE #{table}
          SET id_small = numbered.rn
          FROM numbered
          WHERE #{table}.id = numbered.id
        SQL

        # 3. Set NOT NULL
        change_column_null(table, :id_small, false, 0)

        # 4. Drop old PK (CASCADE drops dependent FKs)
        execute("ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey CASCADE")

        # 5. Rename old id for reference in next step
        rename_column(table, :id, :id_old_string)

        # 6. Promote smallint to id

        rename_column(table, :id_small, :id)

        # 7. Add new PK
        execute("ALTER TABLE #{table} ADD PRIMARY KEY (id)")

        # 8. Add CHECK constraint
        execute("ALTER TABLE #{table} ADD CONSTRAINT chk_#{table}_id_positive CHECK (id >= 0)")

        # 9. Maintain unique index on key
        # The index should already exist, but we ensure it's there
        add_index(table, :key, unique: true, name: "index_#{table}_on_key", if_not_exists: true)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
