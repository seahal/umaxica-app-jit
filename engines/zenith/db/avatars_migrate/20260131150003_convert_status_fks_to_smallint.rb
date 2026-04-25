# typed: false
# frozen_string_literal: true

class ConvertStatusFksToSmallint < ActiveRecord::Migration[8.2]
  FK_MAPPINGS = [
    { table: 'avatar_memberships', fk: 'avatar_membership_status_id', ref_table: 'avatar_membership_statuses' },
    { table: 'avatar_monikers', fk: 'avatar_moniker_status_id', ref_table: 'avatar_moniker_statuses' },
    { table: 'avatar_ownership_periods', fk: 'avatar_ownership_status_id', ref_table: 'avatar_ownership_statuses' },
    { table: 'handle_assignments', fk: 'handle_assignment_status_id', ref_table: 'handle_assignment_statuses' },
    { table: 'handles', fk: 'handle_status_id', ref_table: 'handle_statuses' },
    { table: 'posts', fk: 'post_status_id', ref_table: 'post_statuses' },
    { table: 'post_reviews', fk: 'post_review_status_id', ref_table: 'post_review_statuses' },
  ].freeze

  def up
    FK_MAPPINGS.each do |mapping|
      table = mapping[:table]
      fk = mapping[:fk]
      ref_table = mapping[:ref_table]
      fk_small = "#{fk}_small"

      safety_assured do
        # 1. Add new FK column
        add_column(table, fk_small, :integer, limit: 2, default: 0)

        # 2. Backfill: Join with reference table on old string id

        execute(<<~SQL.squish)
          UPDATE #{table} t
          SET #{fk_small} = r.id
          FROM #{ref_table} r
          WHERE t.#{fk} = r.id_old_string
        SQL

        # 3. Remove old index
        remove_index(table, fk, if_exists: true)

        # 4. Remove old check constraint if exists

        execute("ALTER TABLE #{table} DROP CONSTRAINT IF EXISTS chk_#{table}_#{fk}_format")

        # 5. Drop old column
        remove_column(table, fk)

        # 6. Rename new column
        rename_column(table, fk_small, fk)

        # 7. Handle optional/nullable FKs
        # Some FKs are optional (e.g., avatar_memberships.avatar_membership_status_id)
        # Check schema for nullability
        is_nullable =
          case table
          when 'posts', 'post_reviews'
            false
          else
            true
          end

        if is_nullable
          # Set default to NULL for optional FKs
          change_column_default(table, fk, from: 0, to: nil)
        else
          # Set NOT NULL for required FKs
          change_column_null(table, fk, false)
          change_column_default(table, fk, from: 0, to: 0)
        end

        # 8. Add FK constraint
        add_foreign_key(table, ref_table, column: fk)

        # 9. Add index
        add_index(table, fk)

        # 10. Add CHECK constraint for positive values

        execute("ALTER TABLE #{table} ADD CONSTRAINT chk_#{table}_#{fk}_positive CHECK (#{fk} IS NULL OR #{fk} >= 0)")
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
