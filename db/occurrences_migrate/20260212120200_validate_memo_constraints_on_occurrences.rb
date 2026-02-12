# frozen_string_literal: true

class ValidateMemoConstraintsOnOccurrences < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(
    email_occurrences
    telephone_occurrences
    ip_occurrences
  ).freeze

  def up
    TABLES.each do |table|
      validate_check_constraint table, name: "chk_#{table}_memo_not_null"
      validate_check_constraint table, name: "chk_#{table}_memo_length"
      change_column_null table, :memo, false
      remove_check_constraint table, name: "chk_#{table}_memo_not_null", if_exists: true
    end
  end

  def down
    TABLES.each do |table|
      add_check_constraint table, "memo IS NOT NULL", name: "chk_#{table}_memo_not_null", validate: false
      change_column_null table, :memo, true
    end
  end
end
