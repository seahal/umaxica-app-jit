class CreateOccurrenceConstraints < ActiveRecord::Migration[8.2]
  TABLES = %i[
    email_occurrences
    ip_occurrences
    telephone_occurrences
    zip_occurrences
    area_occurrences
    domain_occurrences
    occurrence_events
  ].freeze

  # To relax the "one body per record" policy for a given table, remove it from
  # this list.
  BODY_UNIQUE_TABLES = TABLES.dup.freeze

  def up
    TABLES.each { |table| enforce_table_constraints(table) }
  end

  def down
    TABLES.reverse_each { |table| relax_table_constraints(table) }
  end

  private

    def enforce_table_constraints(table)
      return unless table_exists?(table)

      change_column_null(table, :public_id, false) if column_exists?(table, :public_id)
      change_column_null(table, :body, false) if column_exists?(table, :body)
      change_column_null(table, :status_id, false) if column_exists?(table, :status_id)

      add_index(table, :public_id, unique: true, name: public_id_index_name(table)) \
        unless index_exists?(table, :public_id, name: public_id_index_name(table))

      if BODY_UNIQUE_TABLES.include?(table) && column_exists?(table, :body)
        add_index(table, :body, unique: true, name: body_index_name(table)) \
          unless index_exists?(table, :body, name: body_index_name(table))
      end

      add_check_constraint(table,
                           "char_length(public_id) = 21",
                           name: public_id_length_constraint_name(table)) unless check_constraint_exists?(table, name: public_id_length_constraint_name(table))

      add_check_constraint(table,
                           "public_id ~ '^[A-Za-z0-9_-]{21}$'",
                           name: public_id_format_constraint_name(table)) unless check_constraint_exists?(table, name: public_id_format_constraint_name(table))
    end

    def relax_table_constraints(table)
      return unless table_exists?(table)

      if check_constraint_exists?(table, name: public_id_format_constraint_name(table))
        remove_check_constraint(table, name: public_id_format_constraint_name(table))
      end

      if check_constraint_exists?(table, name: public_id_length_constraint_name(table))
        remove_check_constraint(table, name: public_id_length_constraint_name(table))
      end

      if BODY_UNIQUE_TABLES.include?(table)
        remove_index(table, name: body_index_name(table)) if index_exists?(table, :body, name: body_index_name(table))
      end

      remove_index(table, name: public_id_index_name(table)) if index_exists?(table, :public_id, name: public_id_index_name(table))

      change_column_null(table, :status_id, true) if column_exists?(table, :status_id)
      change_column_null(table, :body, true) if column_exists?(table, :body)
      change_column_null(table, :public_id, true) if column_exists?(table, :public_id)
    end

    def public_id_index_name(table)
      "index_#{table}_on_public_id"
    end

    def body_index_name(table)
      "index_#{table}_on_body"
    end

    def public_id_length_constraint_name(table)
      "chk_#{table}_public_id_length"
    end

    def public_id_format_constraint_name(table)
      "chk_#{table}_public_id_format"
    end
end
