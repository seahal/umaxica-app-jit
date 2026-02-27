# typed: false
# frozen_string_literal: true

module RawColumnHelpers
  # Read a raw database value without model-level type casting/decryption.
  def raw_column_value(record, column_name)
    klass = record.class
    connection = klass.connection
    quoted_table = connection.quote_table_name(klass.table_name)
    quoted_column = connection.quote_column_name(column_name.to_s)
    sql = klass.send(
      :sanitize_sql_array,
      ["SELECT #{quoted_column} FROM #{quoted_table} WHERE id = ? LIMIT 1", record.id],
    )

    connection.select_value(sql)
  end
end

ActiveSupport.on_load(:active_support_test_case) { include RawColumnHelpers }
