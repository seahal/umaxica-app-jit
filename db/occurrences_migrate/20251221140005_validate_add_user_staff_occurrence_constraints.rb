# frozen_string_literal: true

class ValidateAddUserStaffOccurrenceConstraints < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(
    user_occurrences
    staff_occurrences
  ).freeze

  BODY_UNIQUE_TABLES = TABLES.dup.freeze

  def up
    TABLES.each { |table| validate_table_constraints(table) }
  end

  def down
    TABLES.reverse_each { |table| unvalidate_table_constraints(table) }
  end

  private

  def validate_table_constraints(table)
    return unless table_exists?(table)

    validate_check_constraint(table, name: public_id_null_constraint_name(table)) if check_constraint_exists?(
      table,
      name: public_id_null_constraint_name(table),
    )
    validate_check_constraint(table, name: body_null_constraint_name(table)) if check_constraint_exists?(
      table,
      name: body_null_constraint_name(table),
    )
    validate_check_constraint(table, name: status_id_null_constraint_name(table)) if check_constraint_exists?(
      table,
      name: status_id_null_constraint_name(table),
    )

    validate_check_constraint(table, name: public_id_length_constraint_name(table)) if check_constraint_exists?(
      table,
      name: public_id_length_constraint_name(table),
    )
    validate_check_constraint(table, name: public_id_format_constraint_name(table)) if check_constraint_exists?(
      table,
      name: public_id_format_constraint_name(table),
    )

    change_column_null(table, :public_id, false) if column_exists?(table, :public_id)
    change_column_null(table, :body, false) if column_exists?(table, :body)
    change_column_null(table, :status_id, false) if column_exists?(table, :status_id)

    remove_check_constraint(table, name: public_id_null_constraint_name(table)) if check_constraint_exists?(
      table,
      name: public_id_null_constraint_name(table),
    )
    remove_check_constraint(table, name: body_null_constraint_name(table)) if check_constraint_exists?(
      table,
      name: body_null_constraint_name(table),
    )
    remove_check_constraint(table, name: status_id_null_constraint_name(table)) if check_constraint_exists?(
      table,
      name: status_id_null_constraint_name(table),
    )
  end

  def unvalidate_table_constraints(table)
    return unless table_exists?(table)

    add_check_constraint(table, "public_id IS NOT NULL", name: public_id_null_constraint_name(table), validate: false) if column_exists?(
      table,
      :public_id,
    )
    add_check_constraint(table, "body IS NOT NULL", name: body_null_constraint_name(table), validate: false) if column_exists?(
      table,
      :body,
    )
    add_check_constraint(table, "status_id IS NOT NULL", name: status_id_null_constraint_name(table), validate: false) if column_exists?(
      table,
      :status_id,
    )
  end

  def public_id_length_constraint_name(table)
    "chk_#{table}_public_id_length"
  end

  def public_id_format_constraint_name(table)
    "chk_#{table}_public_id_format"
  end

  def public_id_null_constraint_name(table)
    "chk_#{table}_public_id_null"
  end

  def body_null_constraint_name(table)
    "chk_#{table}_body_null"
  end

  def status_id_null_constraint_name(table)
    "chk_#{table}_status_id_null"
  end
end
