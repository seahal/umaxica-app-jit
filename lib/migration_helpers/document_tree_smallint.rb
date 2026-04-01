# typed: false
# frozen_string_literal: true

require_relative "document_reference_smallint"

module MigrationHelpers
  module DocumentTreeSmallint
    include ForeignKeyHelpers
    include DocumentReferenceSmallint

    DEFAULT_PARENT_COLUMN = "parent_id"

    def convert_tree_reference_table(
      table_name:,
      id_sentinel_values: ["NEYO"],
      parent_sentinel_values:,
      parent_column: DEFAULT_PARENT_COLUMN,
      lower_index:,
      check_constraint:,
      parent_index:,
      child_foreign_keys: []
    )
      safety_assured do
        add_column(table_name, :id_small, :integer, limit: 2) unless column_exists?(table_name, :id_small)
        fill_tree_smallint_ids(table_name, id_sentinel_values)
        store_legacy_mapping(table_name)
        change_column_default(table_name, :id_small, from: nil, to: 0)
        change_column_null(table_name, :id_small, false)

        add_column(table_name, :parent_id_small, :integer, limit: 2) unless column_exists?(
          table_name,
          :parent_id_small,
        )
        fill_parent_id_small(table_name, parent_column, parent_sentinel_values)
        change_column_default(table_name, :parent_id_small, from: nil, to: 0)
        change_column_null(table_name, :parent_id_small, false)

        remove_foreign_key(table_name, column: parent_column) if foreign_key_exists?(
          table_name,
          column: parent_column,
        )

        drop_child_foreign_keys(child_foreign_keys)

        remove_index(table_name, name: lower_index) if lower_index && index_exists?(
          table_name,
          name: lower_index,
        )
        remove_index(table_name, name: parent_index) if parent_index && index_exists?(
          table_name,
          name: parent_index,
        )

        remove_check_constraint(table_name, check_constraint) if check_constraint

        drop_primary_key_constraint(table_name)
        remove_column(table_name, :id) if column_exists?(table_name, :id)
        remove_column(table_name, parent_column) if column_exists?(table_name, parent_column)

        rename_column(table_name, :id_small, :id)

        rename_column(table_name, :parent_id_small, parent_column)

        change_column_default(table_name, :id, from: 0, to: 0)
        change_column_null(table_name, :id, false)
        change_column_default(table_name, parent_column, from: 0, to: 0)
        change_column_null(table_name, parent_column, false)

        add_primary_key_constraint(table_name)
        add_check_constraint(table_name, "id >= 0", name: "#{table_name}_id_non_negative")
        add_check_constraint(
          table_name, "#{parent_column} >= 0",
          name: "#{table_name}_#{parent_column}_non_negative",
        )

        add_index(table_name, parent_column, name: parent_index) if parent_index
        add_foreign_key(table_name, table_name, column: parent_column, primary_key: :id, validate: false)
      end
    end

    private

    def fill_tree_smallint_ids(table_name, sentinel_values)
      sentinel_case = tree_sentinel_case(table_name, sentinel_values)

      execute(<<~SQL.squish)
        WITH mapping AS (
          SELECT id,
                 #{sentinel_case} AS new_id
          FROM #{table_name}
        )
        UPDATE #{table_name}
        SET id_small = mapping.new_id
        FROM mapping
        WHERE #{table_name}.id = mapping.id
      SQL
    end

    def fill_parent_id_small(table_name, parent_column, sentinel_values)
      sentinel_condition = tree_in_condition(table_name, parent_column, sentinel_values)
      mapping_table = legacy_mapping_table_name(table_name)

      execute(<<~SQL.squish)
        UPDATE #{table_name}
        SET parent_id_small = CASE
            WHEN #{sentinel_condition} THEN 0
            ELSE mapping.new_id
          END
        FROM #{mapping_table} AS mapping
        WHERE #{table_name}.#{parent_column} = mapping.legacy_id
      SQL

      execute(<<~SQL.squish)
        UPDATE #{table_name}
        SET parent_id_small = 0
        WHERE parent_id_small IS NULL
      SQL
    end

    def tree_sentinel_case(table_name, sentinel_values)
      if sentinel_values.any?
        sentinel_condition = tree_in_condition(table_name, "id", sentinel_values)
        "CASE WHEN #{sentinel_condition} THEN 0 ELSE row_number() OVER (ORDER BY id) END"
      else
        "row_number() OVER (ORDER BY id)"
      end
    end

    def tree_in_condition(table_name, column, values)
      return "FALSE" if values.empty?

      quoted_values = values.map { |value| quote(value) }.join(", ")
      "#{table_name}.#{column} IN (#{quoted_values})"
    end
  end
end
