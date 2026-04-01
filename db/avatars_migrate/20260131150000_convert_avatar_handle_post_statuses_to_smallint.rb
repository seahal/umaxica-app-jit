# frozen_string_literal: true

class ConvertAvatarHandlePostStatusesToSmallint < ActiveRecord::Migration[8.2]
  TABLES = %w(
    avatar_membership_statuses
    avatar_moniker_statuses
    avatar_ownership_statuses
    handle_assignment_statuses
    handle_statuses
    post_statuses
  ).freeze

  def up
    TABLES.each do |table|
      safety_assured do
        # 1. Add new column
        add_column(table, :id_small, :integer, limit: 2)

        # 2. Backfill: ORDER BY id for stable numbering, starting from 1 (0 reserved)
        execute(<<~SQL.squish)
          WITH numbered AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
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

        # 9. Add unique index on id
        add_index(table, :id, unique: true, name: "index_#{table}_on_id")
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
