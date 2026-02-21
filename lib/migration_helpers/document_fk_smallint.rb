# frozen_string_literal: true

module MigrationHelpers
  module DocumentFkSmallint
    include DocumentReferenceSmallint

    def convert_fk_column_to_smallint(table_name:, column_name:, parent_table:, sentinel_values: ["NEYO", "none"],
                                      index_name:, foreign_key_options: {})
      small_column = "#{column_name}_small"

      safety_assured do
        add_column table_name, small_column, :integer, limit: 2 unless column_exists?(table_name, small_column)
        fill_fk_small_column(table_name, column_name, parent_table, sentinel_values, small_column)
        change_column_default table_name, small_column, from: nil, to: 0
        change_column_null table_name, small_column, false

        remove_foreign_key table_name, column: column_name, to_table: parent_table if foreign_key_exists?(
          table_name,
          to_table: parent_table, column: column_name,
        )
        remove_index table_name, name: index_name if index_name && index_exists?(table_name, name: index_name)

        remove_column table_name, column_name if column_exists?(table_name, column_name)
        rename_column table_name, small_column, column_name

        change_column_default table_name, column_name, from: 0, to: 0
        change_column_null table_name, column_name, false

        add_index table_name, column_name, name: index_name if index_name
        add_check_constraint(table_name, "#{column_name} >= 0", name: "#{table_name}_#{column_name}_non_negative")
        add_foreign_key table_name, parent_table, column: column_name, primary_key: :id, **foreign_key_options
      end
    end

    private

    def fill_fk_small_column(table_name, column_name, parent_table, sentinel_values, small_column)
      sentinel_condition = fk_in_condition(table_name, column_name, sentinel_values)

      mapping_table = legacy_mapping_table_name(parent_table)

      execute <<~SQL.squish
        UPDATE #{table_name}
        SET #{small_column} = CASE
            WHEN #{sentinel_condition} THEN 0
            ELSE mapping.new_id
          END
        FROM #{mapping_table} AS mapping
        WHERE #{table_name}.#{column_name} = mapping.legacy_id
      SQL

      execute <<~SQL.squish
        UPDATE #{table_name}
        SET #{small_column} = 0
        WHERE #{small_column} IS NULL
      SQL
    end

    def fk_in_condition(table_name, column_name, values)
      return "FALSE" if values.empty?

      quoted_values = values.map { |value| quote(value) }.join(", ")
      "#{table_name}.#{column_name} IN (#{quoted_values})"
    end
  end
end
