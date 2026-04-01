# frozen_string_literal: true

class EnforceMemoConstraintsOnOccurrences < ActiveRecord::Migration[8.2]
  TABLES = %i(
    email_occurrences
    telephone_occurrences
    ip_occurrences
  ).freeze

  def up
    TABLES.each do |table|
      safety_assured do
        execute("UPDATE #{table} SET memo = '' WHERE memo IS NULL")
      end
      change_column_default(table, :memo, "")
      add_check_constraint(table, "memo IS NOT NULL", name: "chk_#{table}_memo_not_null", validate: false)
      add_check_constraint(table, "char_length(memo) <= 1000", name: "chk_#{table}_memo_length", validate: false)
    end
  end

  def down
    TABLES.each do |table|
      remove_check_constraint(table, name: "chk_#{table}_memo_not_null")
      remove_check_constraint(table, name: "chk_#{table}_memo_length")
      change_column_default(table, :memo, nil)
    end
  end
end
