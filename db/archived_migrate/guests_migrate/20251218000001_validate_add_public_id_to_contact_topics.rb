# frozen_string_literal: true

class ValidateAddPublicIdToContactTopics < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(app_contact_topics com_contact_topics org_contact_topics).freeze

  def up
    TABLES.each do |table|
      validate_check_constraint(table, name: check_constraint_name_for(table))
      change_column_null(table, :public_id, false)
      remove_check_constraint(table, name: check_constraint_name_for(table))
    end
  end

  def down
    TABLES.each do |table|
      add_check_constraint(
        table,
        "public_id IS NOT NULL",
        name: check_constraint_name_for(table),
        validate: false,
      )
      change_column_null(table, :public_id, true)
    end
  end

  private

  def check_constraint_name_for(table)
    "#{table}_public_id_null"
  end
end
