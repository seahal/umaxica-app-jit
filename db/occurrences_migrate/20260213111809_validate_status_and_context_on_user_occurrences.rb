# frozen_string_literal: true

class ValidateStatusAndContextOnUserOccurrences < ActiveRecord::Migration[8.2]
  def up
    validate_check_constraint(:user_occurrences, name: "user_occurrences_status_id_null")
    change_column_null(:user_occurrences, :status_id, false)
    remove_check_constraint(:user_occurrences, name: "user_occurrences_status_id_null")
  end

  def down
    add_check_constraint(
      :user_occurrences, "status_id IS NOT NULL", name: "user_occurrences_status_id_null",
                                                  validate: false,
    )
    change_column_null(:user_occurrences, :status_id, true)
  end
end
