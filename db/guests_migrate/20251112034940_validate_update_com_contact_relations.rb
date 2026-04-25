# frozen_string_literal: true

class ValidateUpdateComContactRelations < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    validate_com_contact_ids(:com_contact_emails, "com_contact_emails_com_contact_id_null")
    validate_com_contact_ids(:com_contact_telephones, "com_contact_telephones_com_contact_id_null")
  end

  def down
    remove_com_contact_ids(:com_contact_emails, "com_contact_emails_com_contact_id_null")
    remove_com_contact_ids(:com_contact_telephones, "com_contact_telephones_com_contact_id_null")
  end

  private

  def validate_com_contact_ids(table, name)
    return unless table_exists?(table) && column_exists?(table, :com_contact_id)

    validate_check_constraint(table, name: name)
    change_column_null(table, :com_contact_id, false)
    remove_check_constraint(table, name: name)
  end

  def remove_com_contact_ids(table, name)
    return unless table_exists?(table) && column_exists?(table, :com_contact_id)

    add_check_constraint(
      table, "com_contact_id IS NOT NULL",
      name: name,
      validate: false,
    )
    change_column_null(table, :com_contact_id, true)
  end
end
