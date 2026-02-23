# typed: false
# frozen_string_literal: true

module MigrationHelpers
  module ForeignKeyHelpers
    private

    def drop_child_foreign_keys(child_foreign_keys)
      child_foreign_keys.each do |fk|
        next unless fk[:table] && fk[:column]

        if fk[:to_table]
          remove_foreign_key fk[:table], column: fk[:column], to_table: fk[:to_table] if foreign_key_exists?(
            fk[:table], to_table: fk[:to_table], column: fk[:column],
          )
        else
          remove_foreign_key fk[:table], column: fk[:column] if foreign_key_exists?(fk[:table], column: fk[:column])
        end
      end
    end
  end

  module DocumentReferenceSmallint
    include ForeignKeyHelpers

    def convert_string_id_pk_table(table_name:, sentinel_id:, lower_index:, check_constraint:, child_foreign_keys: [])
      safety_assured do
        add_column table_name, :id_small, :integer, limit: 2 unless column_exists?(table_name, :id_small)
        fill_smallint_ids(table_name, sentinel_id)
        store_legacy_mapping(table_name)
        change_column_default table_name, :id_small, from: nil, to: 0
        change_column_null table_name, :id_small, false
        drop_child_foreign_keys(child_foreign_keys)

        remove_index table_name, name: lower_index if lower_index && index_exists?(table_name, name: lower_index)
        remove_check_constraint(table_name, check_constraint) if check_constraint

        drop_primary_key_constraint(table_name)
        remove_column table_name, :id if column_exists?(table_name, :id)

        # rubocop:disable Rails/DangerousColumnNames
        rename_column table_name, :id_small, :id
        # rubocop:enable Rails/DangerousColumnNames
        change_column_default table_name, :id, from: 0, to: 0
        change_column_null table_name, :id, false

        add_primary_key_constraint(table_name)
        add_check_constraint(table_name, "id >= 0", name: "#{table_name}_id_non_negative")
      end
    end

    private

    def fill_smallint_ids(table_name, sentinel_id)
      execute <<~SQL.squish
        WITH mapping AS (
          SELECT id,
                 CASE WHEN id = #{quote(sentinel_id)} THEN 0 ELSE row_number() OVER (ORDER BY id) END AS new_id
          FROM #{table_name}
        )
        UPDATE #{table_name}
        SET id_small = mapping.new_id
        FROM mapping
        WHERE #{table_name}.id = mapping.id
      SQL
    end

    def drop_primary_key_constraint(table_name)
      execute <<~SQL.squish
        ALTER TABLE #{table_name}
        DROP CONSTRAINT IF EXISTS #{table_name}_pkey
      SQL
    end

    def add_primary_key_constraint(table_name)
      execute <<~SQL.squish
        ALTER TABLE #{table_name}
        ADD PRIMARY KEY (id)
      SQL
    end

    def remove_check_constraint(table_name, constraint_name)
      execute <<~SQL.squish
        ALTER TABLE #{table_name}
        DROP CONSTRAINT IF EXISTS #{constraint_name}
      SQL
    end

    def store_legacy_mapping(table_name)
      mapping_table = legacy_mapping_table_name(table_name)

      if table_exists?(mapping_table)
        execute <<~SQL.squish
          TRUNCATE #{mapping_table}
        SQL
      else
        create_table mapping_table do |t|
          t.string :legacy_id, null: false
          t.integer :new_id, null: false, limit: 2
        end
        add_index mapping_table, :legacy_id, name: "#{mapping_table}_legacy_id_idx", unique: true
      end

      execute <<~SQL.squish
        INSERT INTO #{mapping_table} (legacy_id, new_id)
        SELECT id, id_small FROM #{table_name}
      SQL
    end

    def legacy_mapping_table_name(table_name)
      "#{table_name}_legacy_id_map"
    end

    def remove_legacy_mapping(table_name)
      mapping_table = legacy_mapping_table_name(table_name)
      drop_table mapping_table if table_exists?(mapping_table)
    end
  end
end
